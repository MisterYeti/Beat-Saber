using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicTiming : MonoBehaviour
{
    public static MusicTiming Instance = null;

    private Spawner spawner;
    private float beat = (60.0f / 100.0f) * 2;

    void Awake()
    {
        if (Instance == null)
            Instance = this;
        else if (Instance != this)
            Destroy(gameObject);
    }

    private void Start()
    {
        spawner = FindObjectOfType<Spawner>();
        StartCoroutine(MusicTempo());
    }

    public IEnumerator MusicTempo()
    {
        //Default beat 
        beat = 1.2f;
        spawner.SetBeat(beat);

        yield return new WaitForSeconds(40.0f);
        //Drop beat
        beat = 0.6f;
        spawner.SetBeat(beat);

        yield return new WaitForSeconds(19.0f);

        //Default beat 
        beat = 1.2f;
        spawner.SetBeat(beat);

        yield return new WaitForSeconds(41.0f);

        //Drop beat
        beat = 0.6f;
        spawner.SetBeat(beat);

        yield return new WaitForSeconds(38.0f);

        //Default beat 
        beat = 1.2f;
        spawner.SetBeat(beat);

        yield return new WaitForSeconds(20.0f);

        //Drop beat
        beat = 0.6f;
        spawner.SetBeat(beat);

        yield return new WaitForSeconds(38.0f);

        //Default beat 
        beat = 1.2f;
        spawner.SetBeat(beat);

    }
}
