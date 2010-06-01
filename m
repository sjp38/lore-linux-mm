Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5247C6B01B6
	for <linux-mm@kvack.org>; Mon, 31 May 2010 20:57:13 -0400 (EDT)
Received: by vws13 with SMTP id 13so5533666vws.14
        for <linux-mm@kvack.org>; Mon, 31 May 2010 17:57:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2073679454094428814@unknownmsgid>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512134029.36c286c4@annuminas.surriel.com> <20100512210216.GP24989@csn.ul.ie>
	<4BEB18BB.5010803@redhat.com> <20100513095439.GA27949@csn.ul.ie>
	<20100513103356.25665186@annuminas.surriel.com> <20100513140919.0a037845.akpm@linux-foundation.org>
	<4BFC9CCF.6000809@redhat.com> <20100525211520.16e3a034.akpm@linux-foundation.org>
	<2073679454094428814@unknownmsgid>
From: james toy <toyj@union.edu>
Date: Mon, 31 May 2010 20:57:01 -0400
Message-ID: <AANLkTikUTPz3EwOr09rMNDiSRdvlW9Va9Y3_YuQMecLj@mail.gmail.com>
Subject: Re: [PATCH -v2 4/5] always lock the root (oldest) anon_vma
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: james toy <nil@0xabadba.be>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, james toy <mail@wfys.org>, James Toy <0xbaadface@gmail.com>
List-ID: <linux-mm.kvack.org>

This is now fixed; I am truly sorry for the delay but it was out of my
hands.  The sysadmin had git 1.7.1 but an old version of guilt (0.3.2)
which was incompatible.  After the upgrade the watchdog program is
working fine.  Again thanks for alerting me to this and i'll be
keeping a closer eye on it since i'm working on the kernel more now
days.

respectfully,

=3Djt

On Wed, May 26, 2010 at 01:46, james toy <nil@0xabadba.be> wrote:
> I'll get after this asap; sorry. =A0I'm finishing my last trimester of
> my B.S. =A0I'll send a message when it's back up with the offending patch=
.
>
> =3Djt
>
> On May 26, 2010, at 0:15, Andrew Morton <akpm@linux-foundation.org>
> wrote:
>
>> On Wed, 26 May 2010 00:00:15 -0400 Rik van Riel <riel@redhat.com>
>> wrote:
>>
>>> On 05/13/2010 05:09 PM, Andrew Morton wrote:
>>>
>>>> I'm not very confident in merging all these onto the current MM
>>>> pile.
>>>
>>> Blah. =A0I thought I just did that (and wondered why it was
>>> so easy), and then I saw that the MMOTM git tree is old
>>> and does not have the COMPACTION code :(
>>>
>>
>> Oh. =A0James's mmotm->git bot might have broken.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
