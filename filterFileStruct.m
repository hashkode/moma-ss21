function fileNames = filterFileStruct(fileStruct, dataFileMask, fileType)
%FILTERFILESTRUCT Filter a struct of files with a filename mask
%   This function filters struct arrays as returned by the "dir" function
%   and a filter mask from type string as input. It applies the filter mask
%   to the struct array and removes all non-matching elements.
%   The Input File Type filters data according to the walking type
%   <Normal/Silly>.
%   Outputs:
%    fileNames - array of type string with filenames that passed the
%    filter
fileFilter = false(size(fileStruct, 1), 1);
fileNames = string(zeros(size(fileStruct, 1), 1));
for i = 1:size(fileStruct, 1)
    fileNames(i) = string(fileStruct(i).name);
    if ((contains(fileStruct(i).name, dataFileMask)) && (contains(fileStruct(i).name, fileType)))
        fileFilter(i) = 1;
    end
end
fileNames = fileNames(fileFilter);
end
