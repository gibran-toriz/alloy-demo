import time
import os
import psutil

def get_memory_usage():
    process = psutil.Process(os.getpid())
    return process.memory_info().rss / 1024 / 1024  # Convert to MB

def usar_ram(chunk_size_mb: int = 50, target_mb: int = 1000):
    """
    Asigna memoria rápidamente hasta alcanzar target_mb MB y luego la mantiene.
    
    Args:
        chunk_size_mb: Tamaño de cada bloque de memoria a asignar en MB
        target_mb: Memoria total a asignar en MB
    """
    print(f"🚀 Iniciando simulación: asignando hasta {target_mb}MB en bloques de {chunk_size_mb}MB")
    print(f"📊 Límite de memoria del contenedor: {os.getenv('DOCKER_MEMORY_LIMIT', 'No establecido')}MB")
    carga = []
    total_allocated = 0
    
    try:
        while total_allocated < target_mb:
            # Asignar chunk_size_mb MB de una vez
            chunk = bytearray(chunk_size_mb * 1024 * 1024
                              )  # chunk_size_mb MB
            carga.append(chunk)
            total_allocated += chunk_size_mb
            real_usage = get_memory_usage()
            print(f"➕ Asignados {chunk_size_mb}MB - Total asignado: {total_allocated}MB - Uso real: {real_usage:.1f}MB")
            time.sleep(5)  # Rápido, pero no instantáneo
        
        print(f"✅ Memoria objetivo alcanzada: {total_allocated}MB. Manteniendo uso de RAM...")
        print(f"💾 Uso real de memoria: {get_memory_usage():.1f}MB")
        
        while True:
            # Mantener la memoria asignada y reportar uso
            time.sleep(10)
            print(f"📊 Uso actual de memoria: {get_memory_usage():.1f}MB")
            
    except KeyboardInterrupt:
        print("\n🛑 Simulación de RAM detenida.")
        print(f"📊 Memoria total asignada: {total_allocated}MB")
        print(f"📊 Uso real final de memoria: {get_memory_usage():.1f}MB")

if __name__ == "__main__":
    usar_ram(chunk_size_mb=500, target_mb=6000)
