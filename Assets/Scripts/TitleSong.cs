using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TitleSong : MonoBehaviour
{
    public Text TitleSongText;

    private string song,newSong;
    int maxLetters;

    int indexMin = 0;
    int indexMax = 12;
    int lenght = 12;

    private void Start()
    {
        song = "Møme - Aloha ft.Merryn Jeann                     ";
        TitleSongText.text = song.Substring(0,12);
        maxLetters = song.Length;

        StartCoroutine(Defilement());
    }

    IEnumerator Defilement()
    {
        while (true)
        {
            yield return new WaitForSeconds(1.2f);

            while ((indexMax+indexMin) < maxLetters)
            {
                indexMax += 1;
                indexMin += 1;

                newSong = song.Substring(indexMin, lenght);
                TitleSongText.text = newSong;
                yield return new WaitForSeconds(0.3f);
            }
            indexMin = 0; 
            indexMax = 12;
            TitleSongText.text = song.Substring(0, 12);
        }
    }

}
