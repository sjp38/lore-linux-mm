Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F59A6B0071
	for <linux-mm@kvack.org>; Sun, 20 Jun 2010 20:52:57 -0400 (EDT)
Received: by bwz4 with SMTP id 4so1148927bwz.14
        for <linux-mm@kvack.org>; Sun, 20 Jun 2010 17:52:54 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 20 Jun 2010 20:52:54 -0400
Message-ID: <AANLkTilE0nMsbnkfaQM1vLrSaPeiv5ONgAftI51dQXHO@mail.gmail.com>
Subject: TMPFS permissions bug in 2.6.35-rc3
From: Chuck Fox <cfox04@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: hughd@google.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh & List:

   I've encountered a bug in 2.6.35-RC3 where my /tmp directory
(mounted using tmpfs) returns a "File too large" error when adding
execute privileges for the group permission byte:
       Example:
           touch /tmp/afile
           chmod 767 /tmp/afile   # example where chmod works fine
setting bits that are not the group execute bit
           chmod 755 /tmp/afile
           chmod: changing permissions of `/tmp/afile': File too large  # bug

   There are several gigabytes of free RAM + several more gigabytes of
swap space available.

   Here's more information:

   scripts/ver_linux

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux alpha1 2.6.35-rc3-next-20100614 #5 SMP Sun Jun 20 18:55:35 EDT
2010 x86_64 Intel(R) Core(TM)2 Duo CPU E8400 @ 3.00GHz GenuineIntel
GNU/Linux

Gnu C                  4.5.0
Gnu make               3.81
binutils               2.20.1.20100521
util-linux             2.17.2
mount                  support
module-init-tools      3.11.1
e2fsprogs              1.41.12
Linux C Library        2.12
Dynamic linker (ldd)   2.12
Linux C++ Library      6.0.14
Procps                 3.2.8
Net-tools              1.60
Kbd                    1.15.2
Sh-utils               8.5
Modules Loaded         w83627ehf hwmon_vid coretemp
snd_hda_codec_analog nvidia snd_seq_dummy snd_seq_oss
snd_seq_midi_event snd_seq snd_seq_device tun snd_pcm_oss
snd_mixer_oss i2c_i801 sg snd_hda_intel snd_hda_codec snd_pcm
snd_page_alloc e1000e sky2


My fstab entries for mounting /dev/shm and for /tmp:

tmpfs                   /dev/shm      tmpfs     defaults            0      0
tmpfs /tmp tmpfs defaults,noatime,nosuid,mode=1777 0 0


Let me know if there is anything else I can provide to help hunt down the bug!

P.S. --> I got your email from a list of kernel maintainers, if there
is another address this report should go to, please let me know & I'll
forward it.

-- 
Chuck Fox

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
