defmodule Cocina do
  def preparar(%Orden{id: id, item: item, prep_ms: ms}) do
    :timer.sleep(ms)
    IO.puts("Servidor: Orden #{id} de #{item} lista en #{ms} ms")
    {id, "#{item} preparado en #{ms} ms"}
  end
end

defmodule NodoServidor do
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_proceso :servicio_cocina

  def main() do
    IO.puts("SERVIDOR COCINA INICIADO")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    loop()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp loop() do
    receive do
      {cliente, :fin} ->
        send(cliente, :fin)
        loop()

      {cliente, {:preparar, %Orden{} = orden}} ->
        resultado = Cocina.preparar(orden)
        send(cliente, resultado)
        loop()

      otro ->
        IO.puts("Servidor: mensaje desconocido -> #{inspect(otro)}")
        loop()
    end
  end
end

NodoServidor.main()
