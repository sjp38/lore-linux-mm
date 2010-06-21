Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 254A76B0071
	for <linux-mm@kvack.org>; Sun, 20 Jun 2010 22:43:19 -0400 (EDT)
Received: by bwz4 with SMTP id 4so1169600bwz.14
        for <linux-mm@kvack.org>; Sun, 20 Jun 2010 19:43:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTilE0nMsbnkfaQM1vLrSaPeiv5ONgAftI51dQXHO@mail.gmail.com>
References: <AANLkTilE0nMsbnkfaQM1vLrSaPeiv5ONgAftI51dQXHO@mail.gmail.com>
Date: Sun, 20 Jun 2010 22:43:16 -0400
Message-ID: <AANLkTikJOBAMzpwwSQNOqbTPAvJOB-LiElv8g-QWgsWW@mail.gmail.com>
Subject: Re: TMPFS permissions bug in 2.6.35-rc3
From: Chuck Fox <cfox04@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: hughd@google.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Some more information on the bug:

   1. If the superuser is the owner of the file in the tmpfs
filesystem, then the chmod command will work appropriately for the
superuser.
         a. this applies even if I change the group of the file to the
same group as a regular user, the bug does not appear as long as the
owner is 'root'
   2. If the superuser is not the owner of the file, then the bug
appears even if the superuser invokes chmod on the file.
   3. I originally had the posix_acl support for tmpfs turned on, but
I reconfigured the kernel with it turned off.. the bug was unaffected.


On Sun, Jun 20, 2010 at 8:52 PM, Chuck Fox <cfox04@gmail.com> wrote:
> Hugh & List:
>
> =A0 I've encountered a bug in 2.6.35-RC3 where my /tmp directory
> (mounted using tmpfs) returns a "File too large" error when adding
> execute privileges for the group permission byte:
> =A0 =A0 =A0 Example:
> =A0 =A0 =A0 =A0 =A0 touch /tmp/afile
> =A0 =A0 =A0 =A0 =A0 chmod 767 /tmp/afile =A0 # example where chmod works =
fine
> setting bits that are not the group execute bit
> =A0 =A0 =A0 =A0 =A0 chmod 755 /tmp/afile
> =A0 =A0 =A0 =A0 =A0 chmod: changing permissions of `/tmp/afile': File too=
 large =A0# bug
>
> =A0 There are several gigabytes of free RAM + several more gigabytes of
> swap space available.
>
> =A0 Here's more information:
>
> =A0 scripts/ver_linux
>
> If some fields are empty or look unusual you may have an old version.
> Compare to the current minimal requirements in Documentation/Changes.
>
> Linux alpha1 2.6.35-rc3-next-20100614 #5 SMP Sun Jun 20 18:55:35 EDT
> 2010 x86_64 Intel(R) Core(TM)2 Duo CPU E8400 @ 3.00GHz GenuineIntel
> GNU/Linux
>
> Gnu C =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A04.5.0
> Gnu make =A0 =A0 =A0 =A0 =A0 =A0 =A0 3.81
> binutils =A0 =A0 =A0 =A0 =A0 =A0 =A0 2.20.1.20100521
> util-linux =A0 =A0 =A0 =A0 =A0 =A0 2.17.2
> mount =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0support
> module-init-tools =A0 =A0 =A03.11.1
> e2fsprogs =A0 =A0 =A0 =A0 =A0 =A0 =A01.41.12
> Linux C Library =A0 =A0 =A0 =A02.12
> Dynamic linker (ldd) =A0 2.12
> Linux C++ Library =A0 =A0 =A06.0.14
> Procps =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3.2.8
> Net-tools =A0 =A0 =A0 =A0 =A0 =A0 =A01.60
> Kbd =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01.15.2
> Sh-utils =A0 =A0 =A0 =A0 =A0 =A0 =A0 8.5
> Modules Loaded =A0 =A0 =A0 =A0 w83627ehf hwmon_vid coretemp
> snd_hda_codec_analog nvidia snd_seq_dummy snd_seq_oss
> snd_seq_midi_event snd_seq snd_seq_device tun snd_pcm_oss
> snd_mixer_oss i2c_i801 sg snd_hda_intel snd_hda_codec snd_pcm
> snd_page_alloc e1000e sky2
>
>
> My fstab entries for mounting /dev/shm and for /tmp:
>
> tmpfs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /dev/shm =A0 =A0 =A0tmpfs =A0 =
=A0 defaults =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A00
> tmpfs /tmp tmpfs defaults,noatime,nosuid,mode=3D1777 0 0
>
>
> Let me know if there is anything else I can provide to help hunt down the=
 bug!
>
> P.S. --> I got your email from a list of kernel maintainers, if there
> is another address this report should go to, please let me know & I'll
> forward it.
>
> --
> Chuck Fox
>



--=20
Chuck Fox

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
