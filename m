Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 557C26B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 06:28:29 -0400 (EDT)
Message-ID: <4A225ADD.5070605@cs.helsinki.fi>
Date: Sun, 31 May 2009 13:24:29 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
References: <20090528090836.GB6715@elte.hu>	<20090530082048.GM29711@oblivion.subreption.com>	<20090530173428.GA20013@elte.hu>	<20090530180333.GH6535@oblivion.subreption.com>	<20090530182113.GA25237@elte.hu>	<20090530184534.GJ6535@oblivion.subreption.com>	<20090530190828.GA31199@elte.hu>	<4A21999E.5050606@redhat.com>	<84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com>	<20090531001052.40ac57d2@lxorguk.ukuu.org.uk>	<84144f020905302314w12c4c7f8jc8241e36c847f53e@mail.gmail.com> <20090531112440.50cbc4fd@lxorguk.ukuu.org.uk>
In-Reply-To: <20090531112440.50cbc4fd@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Alan,

On Sun, May 31, 2009 at 2:10 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>>> #2 Using kzfree() to clear specific bits of memory (and I question the
>>> kzfree implementation as it seems ksize can return numbers much much
>>> bigger than the allocated space you need to clear - correct but oversize)
>>> or using other flags. I'd favour kzfree personally (and fixing it to work
>>> properly)
>> Well, yes, that's what kzfree() needs to do given the current API. I
>> am not sure why you think it's a problem, though. Adding a size
>> argument to the function will make it more error prone.

Alan Cox wrote:
> Definitely - am I right however that 
> 
> 	x = kzalloc(size, flags)
> 	blah
> 	kzfree(x)
> 
> can memset a good deal more memory (still safely) than "size" to zero ?

Yes because we actually _allocate_ more than requested the 'size' and 
the generic allocator has no way of knowing whether how much of the 
allocated region was actually used by the caller.

Alan Cox wrote:
> That has performance relevance if so and it ought to at least be
> documented.

Makes sense.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
