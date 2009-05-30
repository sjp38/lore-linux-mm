Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0158C6B00D7
	for <linux-mm@kvack.org>; Sat, 30 May 2009 11:05:35 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so2867466yxh.26
        for <linux-mm@kvack.org>; Sat, 30 May 2009 08:05:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090530082048.GM29711@oblivion.subreption.com>
References: <20090522113809.GB13971@oblivion.subreption.com>
	<4A187BDE.5070601@redhat.com> <20090527223421.GA9503@elte.hu>
	<20090528072702.796622b6@lxorguk.ukuu.org.uk> <20090528090836.GB6715@elte.hu>
	<20090528125042.28c2676f@lxorguk.ukuu.org.uk> <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com>
	<20090530075033.GL29711@oblivion.subreption.com> <4A20E601.9070405@cs.helsinki.fi>
	<20090530082048.GM29711@oblivion.subreption.com>
From: Ray Lee <ray-lk@madrabbit.org>
Date: Sat, 30 May 2009 08:05:17 -0700
Message-ID: <2c0942db0905300805h4cd3f8eew32a0b7f5bd50e7be@mail.gmail.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, May 30, 2009 at 1:20 AM, Larry H. <research@subreption.com> wrote:
> On 10:53 Sat 30 May =C2=A0 =C2=A0 , Pekka Enberg wrote:
>>> That's hopeless, and kzfree is broken. Like I said in my earlier reply,
>>> please test that yourself to see the results. Whoever wrote that ignore=
d
>>> how SLAB/SLUB work and if kzfree had been used somewhere in the kernel
>>> before, it should have been noticed long time ago.
>>
>> An open-coded version of kzfree was being used in the kernel:
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dc=
ommitdiff;h=3D00fcf2cb6f6bb421851c3ba062c0a36760ea6e53
>>
>> Can we now get to the part where you explain how it's broken because I
>> obviously "ignored how SLAB/SLUB works"?
>
> You can find the answer in the code of sanitize_obj, within my kfree
> patch. Besides, it would have taken less time for you to write a simple
> module that kmallocs and kzfrees a buffer, than writing these two
> emails.

How about, for the third time, just sharing that information with the
whole rest of us reading along? Do you really think it's useful for
dozens of us to go do that test, when you already obviously *have*,
and could just share the information?

Please, act like a member of the community and share what you know. If
you're unwilling to do so, that's a huge argument in favor of ignoring
your code, no matter how good or right it might be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
