Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 04E9B6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:51:59 -0500 (EST)
Received: by dadv6 with SMTP id v6so6461367dad.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:51:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.02.1202140929040.2721@tux.localdomain>
References: <1329204499-2671-1-git-send-email-hamo.by@gmail.com> <alpine.LFD.2.02.1202140929040.2721@tux.localdomain>
From: Yang Bai <hamo.by@gmail.com>
Date: Tue, 14 Feb 2012 15:51:39 +0800
Message-ID: <CAO_0yfPtibyYKZWtf0y3nFaijcuEKZbejaWsOFebrEinv_O0_Q@mail.gmail.com>
Subject: Re: [PATCH] slab: warning if total alloc size overflow
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, Feb 14, 2012 at 3:31 PM, Pekka Enberg <penberg@kernel.org> wrote:
> On Tue, 14 Feb 2012, Yang Bai wrote:
>
> Did you check how much kernel text size increases? I'm pretty sure we'd n=
eed
> to wrap this with CONFIG_SLAB_OVERFLOW ifdef.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0Pekka

Hi Pekka,

I did not find anything like SLAB_OVERFLOW using grep. Could you
explain it more in detail?

--=20
=C2=A0 =C2=A0 """
=C2=A0 =C2=A0 Keep It Simple,Stupid.
=C2=A0 =C2=A0 """

Chinese Name: =E7=99=BD=E6=9D=A8
Nick Name: Hamo
Homepage: http://hamobai.com/
GPG KEY ID: 0xA4691A33
Key fingerprint =3D 09D5 2D78 8E2B 0995 CF8E=C2=A0 4331 33C4 3D24 A469 1A33

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
