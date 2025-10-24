'use client';

import { useState, useRef } from 'react';
import { Upload } from 'tus-js-client';

export default function Home() {
  const [uploadedFiles, setUploadedFiles] = useState<string[]>([]);
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setUploading(true);
    setProgress(0);

    const upload = new Upload(file, {
      endpoint: 'http://localhost:8080/', // tusd server
      metadata: {
        filename: file.name,
        filetype: file.type,
      },
      onError: (error) => {
        console.error('Upload failed:', error);
        setUploading(false);
        alert('Upload failed: ' + error.message);
      },
      onProgress: (bytesUploaded, bytesTotal) => {
        const percentage = Math.round((bytesUploaded / bytesTotal) * 100);
        setProgress(percentage);
      },
      onSuccess: () => {
        console.log('Upload completed');
        setUploading(false);

        // Use the original filename with extension
        const imageUrl = `http://localhost:8787/${file.name}`;
        setUploadedFiles(prev => [...prev, imageUrl]);

        // Reset file input
        if (fileInputRef.current) {
          fileInputRef.current.value = '';
        }
      },
    });

    upload.start();
  };

  const isImageFile = (url: string) => {
    const extension = url.split('.').pop()?.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(extension || '');
  };

  return (
    <div className="min-h-screen bg-gray-900 py-8 px-4">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold text-center mb-8 text-white">
          File Upload Demo
        </h1>
        <p className="text-center text-gray-300 mb-8">
          Upload files using tusd (resumable uploads) and view them served by static-web-server
        </p>

        {/* Upload Section */}
        <div className="bg-gray-800 rounded-lg shadow-md p-6 mb-8 border border-gray-700">
          <h2 className="text-xl font-semibold mb-4 text-white">Upload File</h2>

          <div className="space-y-4">
            <input
              ref={fileInputRef}
              type="file"
              onChange={handleFileUpload}
              disabled={uploading}
              className="block w-full text-sm text-gray-300 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-600 file:text-white hover:file:bg-blue-700 disabled:opacity-50 bg-gray-700 border border-gray-600 rounded-lg"
            />

            {uploading && (
              <div className="space-y-2">
                <div className="flex justify-between text-sm text-gray-300">
                  <span>Uploading...</span>
                  <span>{progress}%</span>
                </div>
                <div className="w-full bg-gray-700 rounded-full h-2">
                  <div
                    className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                    style={{ width: `${progress}%` }}
                  ></div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Uploaded Files Section */}
        {uploadedFiles.length > 0 && (
          <div className="bg-gray-800 rounded-lg shadow-md p-6 border border-gray-700">
            <h2 className="text-xl font-semibold mb-4 text-white">
              Uploaded Files ({uploadedFiles.length})
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {uploadedFiles.map((url, index) => (
                <div key={index} className="border border-gray-600 rounded-lg p-4 bg-gray-700">
                  <div className="mb-2">
                    <a
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-blue-400 hover:text-blue-300 text-sm font-medium break-all"
                    >
                      {url.split('/').pop()}
                    </a>
                  </div>

                  {isImageFile(url) ? (
                    <img
                      src={url}
                      alt={`Uploaded file ${index + 1}`}
                      className="w-full h-48 object-cover rounded"
                      onError={(e) => {
                        e.currentTarget.style.display = 'none';
                        e.currentTarget.nextElementSibling!.classList.remove('hidden');
                      }}
                    />
                  ) : null}

                  <div className={`text-center text-gray-400 text-sm mt-2 ${isImageFile(url) ? 'hidden' : ''}`}>
                    File uploaded successfully
                  </div>

                  <div className="mt-2 text-xs text-gray-500 break-all">
                    Served from: static-web-server (port 8787)
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Instructions */}
        <div className="bg-blue-900 border border-blue-700 rounded-lg p-4 mt-8">
          <h3 className="font-semibold text-blue-200 mb-2">How it works:</h3>
          <ul className="text-sm text-blue-300 space-y-1">
            <li>• Files are uploaded to <strong>tusd</strong> on port 8080 (resumable uploads)</li>
            <li>• After upload, files are served by <strong>static-web-server</strong> on port 8787</li>
            <li>• Images are displayed directly in the browser</li>
            <li>• Make sure both servers are running before uploading</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
