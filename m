Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7C96F6B00AF
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 06:11:16 -0500 (EST)
Received: by fxm13 with SMTP id 13so8138524fxm.14
        for <linux-mm@kvack.org>; Sun, 05 Dec 2010 03:11:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <m2wroynj4t.fsf@igel.home>
References: <alpine.DEB.2.00.1010312135110.22279@ayla.of.borg>
	<m2wroynj4t.fsf@igel.home>
Date: Sun, 5 Dec 2010 12:11:14 +0100
Message-ID: <AANLkTimfSh8QYLr1bvxcKUwtRLRLLM1J3CCn8uYmKY7v@mail.gmail.com>
Subject: Re: [PATCH/RFC] m68k/sun3: Kill pte_unmap() warnings
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andreas Schwab <schwab@linux-m68k.org>
Cc: Sam Creasey <sammy@sammy.net>, Andrew Morton <akpm@linux-foundation.org>, Linux/m68k <linux-m68k@vger.kernel.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Oct 31, 2010 at 22:32, Andreas Schwab <schwab@linux-m68k.org> wrote=
:
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>
>> Which one is preferable?
>>
>> ------------------------------------------------------------------------=
-------
>> Since commit 31c911329e048b715a1dfeaaf617be9430fd7f4e ("mm: check the ar=
gument
>> of kunmap on architectures without highmem"), we get lots of warnings li=
ke
>>
>> arch/m68k/kernel/sys_m68k.c:508: warning: passing argument 1 of =E2=80=
=98kunmap=E2=80=99 from incompatible pointer type
>>
>> As m68k doesn't support highmem anyway, open code the calls to kmap() an=
d
>> kunmap() (the latter is a no-op) to kill the warnings.
>
> I prefer this one, it matches all architectures without CONFIG_HIGHPTE.

Thx, applied for 2.6.38, with updated commit message.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
