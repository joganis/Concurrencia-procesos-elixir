# nodo-servidor.exs

defmodule Carrera do
  @vueltas 3

  def simular_carrera(%Car{piloto: piloto, vuelta_ms: vms, pit_ms: pms}) do
    total =
      Enum.reduce(1..@vueltas, 0, fn _, acc ->
        :timer.sleep(vms)
        acc + vms
      end)

    tiempo_total = total + pms

    IO.puts("Servidor: #{piloto} terminó con #{tiempo_total} ms.")
    {piloto, tiempo_total}
  end
end

defmodule NodoServidor do
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_proceso :servicio_carreras

  def main() do
    IO.puts("SE INICIA EL SERVIDOR")
    iniciar_nodo(@nodo_servidor)
    registrar_servicio(@nombre_proceso)
    procesar_mensajes()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp registrar_servicio(nombre_servicio_local), do: Process.register(self(), nombre_servicio_local)

  defp procesar_mensajes() do
    receive do
      {cliente_pid, :fin} ->

        send(cliente_pid, :fin)
        procesar_mensajes()

      {cliente_pid, {:simular, %Car{} = car}} ->

        respuesta = Carrera.simular_carrera(car)
        send(cliente_pid, respuesta)
        procesar_mensajes()

      {_, otro} ->

        IO.puts("Servidor: recibido mensaje desconocido -> #{inspect(otro)}")
        procesar_mensajes()
    end
  end
end


NodoServidor.main()
