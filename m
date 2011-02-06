Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7AAA38D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 02:25:33 -0500 (EST)
Received: by wwb29 with SMTP id 29so3701808wwb.26
        for <linux-mm@kvack.org>; Sat, 05 Feb 2011 23:25:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110205093632.b76be846.randy.dunlap@oracle.com>
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
	<20110205093632.b76be846.randy.dunlap@oracle.com>
Date: Sun, 6 Feb 2011 09:25:28 +0200
Message-ID: <AANLkTikt=Ytey-n-YYGuXzJWNprEb-_zjuP5YjJGuvgK@mail.gmail.com>
Subject: Re: [PATCH -mmotm] staging/easycap: fix build when SND is not enabled
From: Tomas Winkler <tomasw@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, rmthomas@sciolus.org, driverdevel <devel@driverdev.osuosl.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Feb 5, 2011 at 7:36 PM, Randy Dunlap <randy.dunlap@oracle.com> wrot=
e:
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> Fix easycap build when CONFIG_SOUND is enabled but CONFIG_SND is
> not enabled.
>
> These functions are only built when CONFIG_SND is enabled, so the
> driver should depend on SND.
> This means that having SND enabled is required for the (obsolete)
> EASYCAP_OSS config option.

Actually SND enabled is needed when EASYCAP_OSS is NOT set.
I'm not sure, though how to force it in Kconfig,
I didn't want to use choice ALSA, OSS as the OSS will be removed later.

Unfortunately I cannot do something like
if EASYCAP_OSS =3D=3D n
    select SND
endif

I will try to come with proper fix

Thanks
Tomas




>
> drivers/built-in.o: In function `easycap_usb_disconnect':
> easycap_main.c:(.text+0x2aba20): undefined reference to `snd_card_free'
> drivers/built-in.o: In function `easycap_alsa_probe':
> (.text+0x2b784b): undefined reference to `snd_card_create'
> drivers/built-in.o: In function `easycap_alsa_probe':
> (.text+0x2b78fb): undefined reference to `snd_pcm_new'
> drivers/built-in.o: In function `easycap_alsa_probe':
> (.text+0x2b7916): undefined reference to `snd_pcm_set_ops'
> drivers/built-in.o: In function `easycap_alsa_probe':
> (.text+0x2b795b): undefined reference to `snd_card_register'
> drivers/built-in.o: In function `easycap_alsa_probe':
> (.text+0x2b79d8): undefined reference to `snd_card_free'
> drivers/built-in.o: In function `easycap_alsa_probe':
> (.text+0x2b7a78): undefined reference to `snd_card_free'
> drivers/built-in.o: In function `easycap_alsa_complete':
> (.text+0x2b7e68): undefined reference to `snd_pcm_period_elapsed'
> drivers/built-in.o:(.data+0x2cae8): undefined reference to `snd_pcm_lib_i=
octl'
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: R.M. Thomas <rmthomas@sciolus.org>
> ---
> =C2=A0drivers/staging/easycap/Kconfig | =C2=A0 =C2=A02 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>
> --- mmotm-2011-0204-1515.orig/drivers/staging/easycap/Kconfig
> +++ mmotm-2011-0204-1515/drivers/staging/easycap/Kconfig
> @@ -1,6 +1,6 @@
> =C2=A0config EASYCAP
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tristate "EasyCAP USB ID 05e1:0408 support"
> - =C2=A0 =C2=A0 =C2=A0 depends on USB && VIDEO_DEV && SOUND
> + =C2=A0 =C2=A0 =C2=A0 depends on USB && VIDEO_DEV && SND
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0---help---
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This is an integrated audio/video drive=
r for EasyCAP cards with
> _______________________________________________
> devel mailing list
> devel@linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/devel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
