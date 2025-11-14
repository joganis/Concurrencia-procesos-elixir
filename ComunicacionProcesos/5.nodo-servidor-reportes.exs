defmodule Sucursal do
  defstruct [:id, :ventas]
end

defmodule Reportes do
  def generar(%Sucursal{id: id, ventas: ventas}) do
    :timer.sleep(Enum.random(50..120))

    total =
      ventas
      |> Enum.map(& &1)
      |> Enum.sum()

    top3 =
      ventas
      |> Enum.sort(:desc)
      |> Enum.take(3)

    IO.puts("Servidor: Reporte listo Sucursal #{id}")

    {id, %{total: total, top3: top3}}
  end
end

defmodule NodoServidor do
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_servicio :servicio_reportes

  def main() do
    IO.puts("SERVIDOR REPORTES INICIADO")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_servicio)
    loop()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp loop do
    receive do
      {cliente, :fin} ->
        send(cliente, :fin)
        loop()

      {cliente, {:reporte, %Sucursal{} = s}} ->
        resp = Reportes.generar(s)
        send(cliente, resp)
        loop()

      otro ->
        IO.puts("Servidor → mensaje desconocido: #{inspect(otro)}")
        loop()
    end
  end
end

NodoServidor.main()
