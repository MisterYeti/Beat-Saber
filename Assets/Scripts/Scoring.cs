using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Scoring : MonoBehaviour
{

    public Text ScoreText, MultiplicatorText;

    [HideInInspector] public int Score;
    [HideInInspector] public int Multiplicator = 1;
    private int nbCubesSuccess = 0;
    private int nbCubesForMultiplicator = 5;
    private int pointsPerCube = 1000;



    private void Start()
    {
        Score = 0;
        ScoreText.text = Score.ToString();
    }

    public void CubeDestroyed()
    {
        nbCubesSuccess += 1;
        Score += (pointsPerCube * Multiplicator);


        if (nbCubesSuccess == nbCubesForMultiplicator && Multiplicator <= 4)
        {
            Multiplicator += 1;
            nbCubesSuccess = 0;
        }

        UpdateTexts();
    }

    public void CubeMissed()
    {
        nbCubesSuccess = 0;
        Multiplicator = 1;
        UpdateTexts();
    }

    private void UpdateTexts()
    {
        ScoreText.text = Score.ToString();
        MultiplicatorText.text = "x"+Multiplicator.ToString();
    }


}
