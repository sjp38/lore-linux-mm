Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 40D896B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 06:38:33 -0500 (EST)
Received: by wera13 with SMTP id a13so4957885wer.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 03:38:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201202051107.26634.toralf.foerster@gmx.de>
References: <201202041109.53003.toralf.foerster@gmx.de>
	<201202041536.52189.toralf.foerster@gmx.de>
	<CAJd=RBC-aceg6JUzGEfD3hcwv+0yd2M_N9kpS0v-JDMMKFaj_Q@mail.gmail.com>
	<201202051107.26634.toralf.foerster@gmx.de>
Date: Sun, 5 Feb 2012 19:38:31 +0800
Message-ID: <CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
Subject: Re: swap storm since kernel 3.2.x
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Johannes Stezenbach <js@sig21.net>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

2012/2/5 Toralf F=C3=B6rster <toralf.foerster@gmx.de>:
>
> Hillf Danton wrote at 05:45:40
>> Would you please try the patchset of Rik?
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0https://lkml.org/lkml/2012/1/26/374
>
> It doesn't applied successfully agains 3.2.3 (+patch +f 3.2.5)
> :-(
>
That patchset already in -next tree, mind to try it with
CONFIG_SLUB_DEBUG first disabled, and try again with it enabled?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
