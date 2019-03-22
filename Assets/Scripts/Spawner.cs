using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;

public class Spawner : MonoBehaviour
{
    public GameObject[] Cubes;
    public GameObject[] Points;
    [HideInInspector] public bool dropEffect = false;

    private GameObject point;
    private GameObject lastPoint = null;
    private float timer;
    private float beat;


    private void Start()
    {
    }


    private void Update()
    {    
        if (timer > beat)
        {
            point = Points[Random.Range(0, Points.Length)];
            while (lastPoint == point)
            {
                point = Points[Random.Range(0, Points.Length)];
            }

            lastPoint = point;

            GameObject cubeInstantiated = Instantiate(Cubes[Random.Range(0, Cubes.Length)],
                new Vector3
                (
                    point.gameObject.transform.position.x,
                    point.gameObject.transform.position.y,
                    point.gameObject.transform.position.z
                    ),
                Quaternion.identity,
                point.transform);

            cubeInstantiated.transform.localEulerAngles = 
                new Vector3(0, 180, 90 * Random.Range(0, 4));

            timer -= beat;
        }

        timer += Time.deltaTime;
    }


    public void SetBeat(float beatTempo)
    {
        beat = beatTempo;
    }

    


   



}
