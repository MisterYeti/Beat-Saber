using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cube : MonoBehaviour
{

    public COLOR Color;

    private Scoring scoring;

    private void Start()
    {
        scoring = FindObjectOfType<Scoring>();
    }

    private void Update()
    {
        transform.position += Time.deltaTime * 2.0f * transform.forward;
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log(other.gameObject);
        if (other.gameObject.tag == "death")
        {
            PostProcessingInGame.Instance.Fail();
            scoring.CubeMissed();
            Destroy(gameObject);
        }
    }

}
