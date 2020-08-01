namespace Bansi.InteractiveWater
{
    [System.Serializable]
    public struct WaveAnimationInfo
    {
        public float AmplitudePercentage;
        public float ImpactPositionX;
        public int CurrentFrame;
        public float LastFrameTime;
        public WaveAnimationDirection WaveAnimationDirection;
    }
}