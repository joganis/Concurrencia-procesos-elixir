defmodule NodoCliente do
  @nodo_cliente :"cliente@10.0.67.160"
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_proceso :servicio_cocina

  def lista_ordenes do
    [
      %Orden{id: 1, item: "Café", prep_ms: 500},
      %Orden{id: 2, item: "Sandwich", prep_ms: 700},
      %Orden{id: 3, item: "Té", prep_ms: 300},
      %Orden{id: 4, item: "Croissant", prep_ms: 600}
    ]
  end

  def main() do
    IO.puts("CLIENTE COCINA INICIADO")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      enviar_ordenes()
    else
      IO.puts("No se pudo conectar al servidor")
    end
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  def enviar_ordenes do
    Enum.each(lista_ordenes(), fn orden ->
      send({@nombre_proceso, @nodo_servidor}, {self(), {:preparar, orden}})
    end)

    send({@nombre_proceso, @nodo_servidor}, {self(), :fin})
    recibir()
  end

  defp recibir do
    receive do
      :fin ->
        IO.puts("Cliente: fin recibido. Todo listo.")
        :ok

      {id, descripcion} ->
        IO.puts("Cliente → Orden #{id} lista: #{descripcion}")
        recibir()

      otro ->
        IO.puts("Cliente: mensaje desconocido #{inspect(otro)}")
        recibir()
    end
  end
end

NodoCliente.main()
