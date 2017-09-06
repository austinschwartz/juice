defmodule Juice.Lang do
  def build_compile(source_file, out_dir, language) do
    try do
      case String.downcase(language) do
        "java" ->
          {:ok, "javac #{source_file} -d #{out_dir}"}
        "c" ->
          {:ok, "gcc #{source_file} -o #{out_dir}/a.out"}
        _ -> 
          raise "Language not supported"
      end
    rescue
      e in RuntimeError -> {:error, e.message}
    end
  end
end
