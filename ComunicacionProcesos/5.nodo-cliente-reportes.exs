defmodule NodoCliente do
  @nodo_cliente :"cliente@10.0.67.160"
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_servicio :servicio_reportes

  def lista_sucursales(n \\ 5) do
    Enum.map(1..n, fn i ->
      ventas =
        Enum.map(1..10, fn _ ->
          Enum.random(20..200)
        end)

      %Sucursal{id: i, ventas: ventas}
    end)
  end

  def main do
    IO.puts("CLIENTE REPORTES INICIADO")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      enviar()
    else
      IO.puts("No se pudo conectar al servidor")
    end
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  def enviar do
    sucursales = lista_sucursales()

    Enum.each(sucursales, fn s ->
      send({@nombre_servicio, @nodo_servidor}, {self(), {:reporte, s}})
    end)

    send({@nombre_servicio, @nodo_servidor}, {self(), :fin})

    recibir()
  end

  defp recibir do
    receive do
      :fin ->
        IO.puts("Cliente: finalización recibida.")
        :ok

      {id, datos} ->
        IO.puts("Cliente → Reporte Sucursal #{id}: #{inspect(datos)}")
        recibir()

      otro ->
        IO.puts("Cliente mensaje desconocido #{inspect(otro)}")
        recibir()
    end
  end
end

NodoCliente.main()
