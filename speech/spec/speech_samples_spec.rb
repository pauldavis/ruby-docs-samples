# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../speech_samples"
require "rspec"
require "google/cloud/speech"
require "google/cloud/storage"

describe "Google Cloud Speech API samples" do

  before do
    @project_id  = Google::Cloud::Speech.new.project
    @bucket_name = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @storage     = Google::Cloud::Storage.new
    @bucket      = @storage.bucket @bucket_name

    @storage.create_bucket @bucket_name unless @storage.bucket @bucket_name

    # Path to RAW audio file with sample rate of 16000 using LINEAR16 encoding
    @audio_file_path = File.expand_path "../audio_files/audio.raw", __dir__

    # Expected transcript of spoken English recorded in the audio.raw file
    @audio_file_transcript = "how old is the Brooklyn Bridge"
  end

  example "transcribe audio file" do
    expect {
      speech_sync_recognize project_id:      @project_id,
                            audio_file_path: @audio_file_path
    }.to output("Transcription: #{@audio_file_transcript}\n").to_stdout
  end

  example "transcribe audio file from GCS" do
    file = @bucket.upload_file @audio_file_path, "audio.raw"
    path = "gs://#{file.bucket}/audio.raw"

    expect {
      speech_sync_recognize_gcs project_id:   @project_id,
                                storage_path: path
    }.to output("Transcription: #{@audio_file_transcript}\n").to_stdout
  end

  example "async operation to transcribe audio file" do
    expect {
      speech_async_recognize project_id:      @project_id,
                             audio_file_path: @audio_file_path
    }.to output(
      "Operation started\nTranscription: how old is the Brooklyn Bridge\n"
    ).to_stdout
  end

  example "async operation to transcribe audio file from GCS" do
    file = @bucket.upload_file @audio_file_path, "audio.raw"
    path = "gs://#{file.bucket}/audio.raw"

    expect {
      speech_async_recognize_gcs project_id:   @project_id,
                                 storage_path: path
    }.to output(
      "Operation started\nTranscription: how old is the Brooklyn Bridge\n"
    ).to_stdout
  end

  example "streaming operation to transcribe audio file" do
    expect {
      speech_streaming_recognize project_id:      @project_id,
                                 audio_file_path: @audio_file_path
    }.to output(
      /how old is the Brooklyn Bridge/
    ).to_stdout
  end
end
