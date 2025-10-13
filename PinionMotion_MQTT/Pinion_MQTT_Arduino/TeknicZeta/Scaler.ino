float Scale_Steps_to_mm(int steps) {

  return steps / SCLD;
}

int Scale_mm_to_Steps(float mm) {

  return round(mm * SCLD);
}

float Scale_Vel_Steps_to_mm(int steps) {

  return steps / SCLV;
}

int Scale_Vel_mm_to_Steps(float mm) {

  return round(mm * SCLV);
}

float Scale_Accel_Steps_to_mm(int steps) {

  return steps / SCLA;
}

int Scale_Accel_mm_to_Steps(float mm) {

  return round(mm * SCLA);
}