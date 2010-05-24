Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9E2466B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 07:37:22 -0400 (EDT)
Received: by iwn39 with SMTP id 39so3618690iwn.14
        for <linux-mm@kvack.org>; Mon, 24 May 2010 04:37:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100524110245.6b6d847d@lxorguk.ukuu.org.uk>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils> <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
	<20100524110245.6b6d847d@lxorguk.ukuu.org.uk>
From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Date: Mon, 24 May 2010 12:36:49 +0100
Message-ID: <AANLkTilrt_DXeQcl2SKtRvYTt5DKDtV9DhUyZH3KzAZ8@mail.gmail.com>
Subject: Re: TMPFS over NFSv4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Got it cleared.

BTW, nice example ... US Banking System :-)

__
tharindu.info

"those that can, do. Those that can=92t, complain." -- Linus



On Mon, May 24, 2010 at 11:02 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote=
:
> On Mon, 24 May 2010 10:26:39 +0100
> Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com> wrote:
>
>> thankx a lot Hugh ... I will try this out ... (bit harder patch
>> already patched SLES kernel :-p ) ....
>>
>> BTW, what does Alan means by "strict overcommit" ?
>
> Strict overcommit works like banks should. It tries to ensure that at any
> point it has sufficient swap and memory to fulfill any possible use of
> allocated address space. So in strict overcommit mode you should almost
> never see an OOM kill (there are perverse cases as always), but you will
> need a lot more swap that may well never be used.
>
> In the normal mode the kernel works like the US banking system and makes
> speculative guesses that all the resources it hands out will never be
> needed at once. That has the corresponding risk that one day it might at
> which point you get a meltdown (or in the kernel case OOM kills)
>
> Alan
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
