Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1093A6B003D
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 05:51:35 -0500 (EST)
Received: by fxm7 with SMTP id 7so669049fxm.14
        for <linux-mm@kvack.org>; Sun, 22 Feb 2009 02:51:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <49A0C2D4.20009@zytor.com>
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
	 <1235223364-2097-2-git-send-email-vegard.nossum@gmail.com>
	 <49A0C2D4.20009@zytor.com>
Date: Sun, 22 Feb 2009 11:51:33 +0100
Message-ID: <19f34abd0902220251w4ec0485bp3eaa6092c60447a6@mail.gmail.com>
Subject: Re: [PATCH] kmemcheck: disable fast string operations on P4 CPUs
From: Vegard Nossum <vegard.nossum@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

2009/2/22 H. Peter Anvin <hpa@zytor.com>:
> Vegard Nossum wrote:
>> This patch may allow us to remove the REP emulation code from
>> kmemcheck.
>
>> +#ifdef CONFIG_KMEMCHECK
>> +     /*
>> +      * P4s have a "fast strings" feature which causes single-
>> +      * stepping REP instructions to only generate a #DB on
>> +      * cache-line boundaries.
>> +      *
>> +      * Ingo Molnar reported a Pentium D (model 6) and a Xeon
>> +      * (model 2) with the same problem.
>> +      */
>> +     if (c->x86 == 15) {
>
> If this is supposed to refer to the Intel P4 core, you should exclude
> the post-P4 cores that also have x86 == 15 (e.g. Core 2 and Core i7).
> If those are affected, too, they should be mentioned in the comment.

Thanks for the review!

This is supposed to happen only for those machines where the "fast
string ops" is enabled by default.

We have a test for that in the part that you snipped -- and since the
MSR is architectural, I believe it would exist (i.e. not cause an
error if we read it, but just be cleared by default or hard-wired to
clear) on those post-P4 cores you mentioned too?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
