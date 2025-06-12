import time

def usar_ram(chunk_size_mb: int = 500, target_mb: int = 7000):
    """
    Asigna memoria rápidamente hasta alcanzar target_mb MB y luego la mantiene.
    
    Args:
        chunk_size_mb: Tamaño de cada bloque de memoria a asignar en MB
        target_mb: Memoria total a asignar en MB
    """
    print(f"🚀 Iniciando simulación: asignando hasta {target_mb}MB en bloques de {chunk_size_mb}MB")
    carga = []
    total_allocated = 0
    
    try:
        while total_allocated < target_mb:
            # Asignar chunk_size_mb MB de una vez
            chunk = bytearray(chunk_size_mb * 1024 * 1024)  # chunk_size_mb MB
            carga.append(chunk)
            total_allocated += chunk_size_mb
            print(f"➕ Asignados {chunk_size_mb}MB - Total: {total_allocated}MB")
            time.sleep(0.5)  # Rápido, pero no instantáneo
        
        print(f"✅ Memoria objetivo alcanzada: {total_allocated}MB. Manteniendo uso de RAM...")
        
        while True:
            # Mantener la memoria asignada
            time.sleep(10)
            
    except KeyboardInterrupt:
        print("\n🛑 Simulación de RAM detenida.")
        print(f"📊 Memoria total asignada: {total_allocated}MB")

if __name__ == "__main__":
    usar_ram(chunk_size_mb=500, target_mb=6000)
