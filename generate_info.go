package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

type TusInfo struct {
	ID           string            `json:"ID"`
	Size         int64             `json:"Size"`
	MetaData     map[string]string `json:"MetaData"`
	UploadOffset int64             `json:"UploadOffset"`
	IsPartial    bool              `json:"IsPartial"`
	IsFinal      bool              `json:"IsFinal"`
	Completeness []int64           `json:"Completeness"`
	UploadToken  string            `json:"UploadToken"`
}

func main() {
	rootDir := "./files"
	err := filepath.WalkDir(rootDir, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		if strings.HasSuffix(d.Name(), ".info") {
			return nil
		}

		relPath, err := filepath.Rel(rootDir, path)
		if err != nil {
			return err
		}

		info, err := d.Info()
		if err != nil {
			return err
		}

		size := info.Size()

		tusInfo := TusInfo{
			ID:           filepath.ToSlash(relPath),
			Size:         size,
			MetaData:     map[string]string{"filename": d.Name(), "contentType": "application/octet-stream"},
			UploadOffset: size,
			IsPartial:    false,
			IsFinal:      true,
			Completeness: []int64{0, size},
			UploadToken:  "", // Optional, can generate UUID if needed
		}

		jsonData, err := json.MarshalIndent(tusInfo, "", "  ")
		if err != nil {
			return err
		}

		infoFilePath := path + ".info"
		err = os.WriteFile(infoFilePath, jsonData, 0644)
		if err != nil {
			return err
		}

		fmt.Printf("Created %s\n", infoFilePath)
		return nil
	})

	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
}