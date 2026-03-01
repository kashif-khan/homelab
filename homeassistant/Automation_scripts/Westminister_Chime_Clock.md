# Westminster Chime Clock

This automation turns your family room speaker into a Westminster chime clock. Every 15 minutes during daytime hours, it plays the traditional Westminster quarter-hour melody. On the hour, it plays the fourth quarter melody followed by hour strikes so you always know the time without looking at a clock.

---

## How It Works

The automation fires every 15 minutes and plays a different audio file depending on how far through the current hour you are:

| Minute            | What Plays                                                 |
| :---------------- | :--------------------------------------------------------- |
| :15               | First quarter melody                                       |
| :30               | Second quarter melody                                      |
| :45               | Third quarter melody                                       |
| :00 (top of hour) | Fourth quarter melody, then the hour is struck 1–12 times  |

At the top of each hour, after the fourth quarter melody finishes, there is a **5-second delay** before the hour strikes begin. This pause separates the melody from the strikes, giving it a natural clock-like feel. Each individual strike sound is then separated by a **3-second delay**, so the strikes play one at a time with a clear gap between them.

The hour strikes use a 12-hour format. For example, at 13:00 (1 PM) the clock strikes once, and at 00:00 (midnight) it would strike 12 times — though midnight falls outside the active hours window and will not play.

---

## When It Runs

The automation is **active only between 07:00 and 22:00** (7 AM to 10 PM). Outside of these hours, the time pattern still triggers, but the time condition blocks any sound from playing. This keeps the house quiet overnight.

---

## Requirements

### Audio Files

Five audio files must be placed in the correct folder on your Home Assistant server before this automation will work.

**Folder location on the server:** `/config/www/sounds/westminister/`

| File Name              | Purpose                                          |
| :--------------------- | :----------------------------------------------- |
| `westminister_q1.mp3`  | First quarter melody (plays at :15)              |
| `westminister_q2.mp3`  | Second quarter melody (plays at :30)             |
| `westminister_q3.mp3`  | Third quarter melody (plays at :45)              |
| `westminister_q4.mp3`  | Fourth quarter melody (plays at the top of hour) |
| `strike.mp3`           | Single hour strike sound (repeated per hour)     |

> **Important:** The `/config/www/` directory in Home Assistant is served publicly at `/local/` in the browser. The automation already references the files using the correct `/local/sounds/westminister/` path. You only need to place the files in `/config/www/sounds/westminister/` and the automation will find them automatically.

If the `westminister` folder does not exist yet, create it inside `/config/www/sounds/`. You can upload files using the Home Assistant **File Editor** add-on, **Samba share**, or **SSH**.

### Entities

| Entity                              | Type         | Purpose                            |
| :---------------------------------- | :----------- | :--------------------------------- |
| `media_player.family_room_speaker`  | Media Player | The speaker that plays the chimes  |

No additional integrations are required beyond a working media player entity that supports the `media_player.play_media` action.

---

## Customizable Settings

### Active Hours

The automation currently plays between **07:00 and 22:00**. To change this window, edit the time condition in the automation:

- **`after`** - the earliest time chimes will play (currently `07:00:00`)
- **`before`** - the latest time chimes will play (currently `22:00:00`)

For example, if you want chimes to start at 8 AM and stop at 9 PM, change these to `08:00:00` and `21:00:00`.

### Speaker

The automation targets `media_player.family_room_speaker`. If you want chimes on a different or additional speaker, update this entity ID in each of the play actions within the automation.

### Swap Audio Files

You can replace any of the five MP3 files with your own recordings or alternative chime sounds. As long as the file names and folder location remain the same, no changes to the automation are needed.

---

## Behavior Notes

- **Single mode:** The automation runs in `single` mode. If the automation is already playing (for example, a long hour-strike sequence) when the next 15-minute trigger fires, the new trigger is ignored. This prevents overlapping audio.
- **Strike timing:** At the top of the hour, the 5-second delay after the melody plus the 3-second gaps between strikes means the sequence can be lengthy. At 12 o'clock, for example, the 12 strikes take approximately 41 seconds total after the melody finishes (5s delay + 12 strikes × 3s gaps).
- **No volume control:** Unlike the Namaz Announcements automation, this automation does not set a specific volume before playing. The chimes play at whatever volume the speaker is currently set to.
- **Media player compatibility:** The speaker must support `media_player.play_media` with `audio/mpeg` content. Most smart speakers and media players in Home Assistant support this.

---

## Troubleshooting

**No sound plays at all.**

- Verify the audio files exist at `/config/www/sounds/westminister/` with the exact file names listed above.
- Confirm the speaker entity ID `media_player.family_room_speaker` matches your actual media player in Home Assistant.
- Check that the current time is between 07:00 and 22:00, as chimes are silenced outside this window.

**Only some chimes play (e.g., the quarter melodies work but hour strikes do not).**

- Confirm `strike.mp3` exists in the sounds folder.
- Check that the speaker is not being used by another automation or media source at the top of the hour, which could interrupt playback.

**Chimes play at the wrong times.**

- The automation uses the `time_pattern` trigger set to every 15 minutes. Verify that your Home Assistant system clock is accurate under **Settings > System > General**.

**The automation does not appear in your automation list.**

- Make sure the YAML file has been loaded correctly. In Home Assistant, go to **Settings > Automations & Scenes** and check for any configuration errors reported at the top of the page.

---

## Related Files

- [`Namaz_announcements.yml`](Namaz_announcements.yml) - Announces Islamic prayer times on the same speaker
