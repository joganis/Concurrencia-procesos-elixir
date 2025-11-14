defmodule Notificaciones do

  @costos %{
    push: 40..60,
    email: 60..90,
    sms: 80..120
  }

  def enviar(%Notif{id: id, canal: canal, usuario: user, plantilla: tpl}) do
    :timer.sleep(Enum.random(@costos[canal]))

    IO.puts("Notificación enviada a #{user} (#{canal}) usando plantilla #{tpl}")
    {id, :ok}
  end

  def secuencial(notifs) do
    Enum.map(notifs, &enviar/1)
  end

  def concurrente(notifs) do
    notifs
    |> Enum.map(fn n -> Task.async(fn -> enviar(n) end) end)
    |> Task.await_many()
  end

  def generar_notifs(n \\ 10) do
    canales = [:push, :email, :sms]
    plantillas = [:bienvenida, :alerta, :promo]

    Enum.map(1..n, fn id ->
      %Notif{
        id: id,
        canal: Enum.random(canales),
        usuario: "user#{id}@mail.com",
        plantilla: Enum.random(plantillas)
      }
    end)
  end

  def iniciar do
    notifs = generar_notifs()

    IO.puts("\nENVÍO SECUENCIAL...")
    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({Notificaciones, :secuencial, [notifs]})

    IO.puts("\nENVÍO CONCURRENTE...")
    tiempo_concurrente =
      Benchmark.determinar_tiempo_ejecucion({Notificaciones, :concurrente, [notifs]})

    IO.puts("\nRESULTADOS")
    IO.puts(Benchmark.generar_mensaje(tiempo_secuencial, tiempo_concurrente))

    IO.puts("\nSimulación completada.\n")
  end
end

Notificaciones.iniciar()
