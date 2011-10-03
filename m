Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DE03D9000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 10:03:16 -0400 (EDT)
Received: by iaen33 with SMTP id n33so7665438iae.14
        for <linux-mm@kvack.org>; Mon, 03 Oct 2011 07:03:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADLM8XP09kFhxjMYbxD80+4cS00cm2aWZE1Zvjoby0Afrdz9eQ@mail.gmail.com>
References: <CADLM8XNiaxLFRZXs4NKJmoORvED-DV0bNxPF6eHsfnLqtxw09w@mail.gmail.com>
	<20111003192458.14d198a3.kamezawa.hiroyu@jp.fujitsu.com>
	<CAMuHMdVuMHjbDkAdrkfTS-ZaYCwN-avihsQyDsOAVFt+PdWqYw@mail.gmail.com>
	<CADLM8XP09kFhxjMYbxD80+4cS00cm2aWZE1Zvjoby0Afrdz9eQ@mail.gmail.com>
Date: Mon, 3 Oct 2011 16:03:14 +0200
Message-ID: <CAMuHMdV_aKGscAw1UmQU45VZONtdvYLTK18nTYX4wvg0YLTx4A@mail.gmail.com>
Subject: Re: One comment on the __release_region in kernel/resource.c
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang.kernel@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 3, 2011 at 15:35, Wei Yang <weiyang.kernel@gmail.com> wrote:
> 2011/10/3 Geert Uytterhoeven <geert@linux-m68k.org>
>> On Mon, Oct 3, 2011 at 12:24, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Sun, 2 Oct 2011 21:57:07 +0800
>> > Wei Yang <weiyang.kernel@gmail.com> wrote:
>> >
>> >> Dear experts,
>> >>
>> >> I am viewing the source code of __release_region() in
>> >> kernel/resource.c.
>> >> And I have one comment for the performance issue.
>> >>
>> >> For example, we have a resource tree like this.
>> >> 10-89
>> >> =C2=A0 =C2=A020-79
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A030-49
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A055-59
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A060-64
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A065-69
>> >> =C2=A0 =C2=A080-89
>> >> 100-279
>> >>
>> >> If the caller wants to release a region of [50,59], the original code
>> >> will
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0^^^^^^^
>> Do you really mean [50,59]?
>
> Yes.
>>
>> I don't think that's allowed, as the tree has [55,59], so you would
>> release a
>> larger region that allocated.
>
> So you mean the case I mentioned will not happen?

Indeed, it should not happen.
Actually I'm surprised it doesn't return an error code.

> Actually, I believe every developer should pass the resource region which
> has been allocated.
> While if some one made a mistake and pass a region which is not allocated
> before and overlap
> some "BUSY" region?

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
