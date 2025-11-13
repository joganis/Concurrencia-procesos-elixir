defmodule Text do
  def saludo(msg) do
    IO.puts(msg)
  end

  def positivos(lista) do
    Enum.map(lista, fn x ->
      fn ->
        if x > 0 do
          IO.puts("#{x} es positivo")
        else
          IO.puts("#{x} no es positivo")
        end
      end
    end)
  end

  def concurrent_list (list) do
    Enum.map(list, fn x ->
      

    end)
  end

  def run do
  list = [-10, 5, 0, 3, -1, 8]
  tiempos_secuencial = Benchmark.determinar_tiempo_ejecucion({Text, :positivos, [list]})
  IO.puts("Tiempo secuencial: #{tiempos_secuencial} microsegundos")
end


end

Text.run()

resp2 = spawn(Text, :saludo, ["Hola desde spawn/3"])
IO.puts("PID: #{inspect(resp2)}")

resp = Task.async(fn -> Text.saludo("Hola desde Task.async/1") end)
tarea = Task.async(fn -> Text.saludo("Hola desde Task.async/1 segunda tarea") end)
IO.puts("Task: #{inspect(resp)}")

return = Task.await(resp)
IO.puts("Return: #{inspect(return)}")

retun2 = Task.await(tarea)
IO.puts("Return2: #{inspect(retun2)}")
