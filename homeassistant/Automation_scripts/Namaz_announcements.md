# Namaz Announcements (Family Room Speaker)

This automation announces Islamic prayer times through your family room speaker using text-to-speech. When each of the five daily prayers begins, the speaker plays a spoken reminder so you never miss a prayer time.

---

## How It Works

Every minute, the automation checks whether the current time matches any of the five daily prayer times retrieved from the Islamic Prayer Times integration. If there is a match, the speaker volume is set to the configured level and a spoken announcement is played naming the specific prayer.

The five prayers covered are:

- **Fajr** - pre-dawn prayer
- **Dhuhr** - midday prayer
- **Asr** - afternoon prayer
- **Maghrib** - sunset prayer
- **Isha** - night prayer

---

## When It Runs

The automation checks the time **every minute, all day**. It only plays an announcement at the exact minute that matches a prayer time. On all other minutes, it does nothing.

---

## Requirements

### Integrations

| Integration | Purpose |
|---|---|
| **Islamic Prayer Times** | Provides sensor entities with the daily prayer times |
| **Google Translate TTS** | Converts the announcement text to spoken audio |

> **Note:** The Islamic Prayer Times integration must be installed and configured in Home Assistant before this automation will work. It is available through the Home Assistant integrations page. The integration automatically calculates prayer times based on your configured location.

### Entities

| Entity | Type | Purpose |
|---|---|---|
| `media_player.family_room_speaker` | Media Player | The speaker that plays announcements |
| `sensor.islamic_prayer_times_fajr_prayer` | Sensor | Fajr prayer time |
| `sensor.islamic_prayer_times_dhuhr_prayer` | Sensor | Dhuhr prayer time |
| `sensor.islamic_prayer_times_asr_prayer` | Sensor | Asr prayer time |
| `sensor.islamic_prayer_times_maghrib_prayer` | Sensor | Maghrib prayer time |
| `sensor.islamic_prayer_times_isha_prayer` | Sensor | Isha prayer time |
| `tts.google_translate_en_com` | TTS Service | Text-to-speech engine |

All six sensor entities are created automatically when the Islamic Prayer Times integration is set up.

---

## Customizable Settings

The following values are defined as variables at the top of the automation and are the primary settings you would adjust.

| Variable | Current Value | Description |
|---|---|---|
| `speaker` | `media_player.family_room_speaker` | The entity ID of the speaker to use |
| `vol` | `0.7` | Announcement volume, on a scale of `0.0` (silent) to `1.0` (maximum) |

### Changing the Speaker

If your speaker has a different entity ID, update the `speaker` variable to match. You can find your speaker's entity ID in **Settings > Devices & Services > Entities** within Home Assistant.

### Changing the Volume

The volume is set to `0.7` (70%) for announcements. Raise this value for louder announcements or lower it if the speaker is in a quiet room. Note that this sets the speaker to the specified volume only at the moment of the announcement; it does not restore a previous volume level afterward.

### Changing the Announcement Language

The automation uses Google Translate TTS with English text. To change the language or the TTS engine, you would need to update both the TTS entity (`tts.google_translate_en_com`) and the message text in the action steps.

---

## Behavior Notes

- **Time zone awareness:** Prayer times from the sensor are stored in UTC. The automation converts them to your local time zone before comparing, so the announcements fire at the correct local time.
- **Unavailable sensors:** If a prayer time sensor is unavailable or returns no value, that prayer is silently skipped and no announcement is made.
- **Single mode:** The automation runs in `single` mode, meaning if it is somehow triggered while already running, the new trigger is ignored. This prevents overlapping announcements.
- **No night silence:** This automation runs at any hour of the day. Fajr, for example, may fire in the early morning hours. If you want to suppress announcements during specific hours, a time condition would need to be added.

---

## Troubleshooting

**The speaker does not announce any prayers.**
- Confirm the Islamic Prayer Times integration is installed and that its sensor entities are showing valid times (not `unavailable` or `unknown`) in Developer Tools > States.
- Confirm the speaker entity ID in the `speaker` variable matches your actual media player entity.
- Check that Google Translate TTS is available on your system.

**Announcements fire at the wrong time.**
- Verify your Home Assistant time zone is set correctly under **Settings > System > General**.
- Prayer time calculations depend on your configured location within the Islamic Prayer Times integration settings.

**The speaker volume does not change.**
- Some speakers do not support the `media_player.volume_set` action. Check your speaker's supported features in its entity details page.

---

## Related Files

- [`Westminister_Chime_Clock.yml`](Westminister_Chime_Clock.yml) - Plays Westminster chime melodies every 15 minutes on the same speaker
