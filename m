Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80E286B00F2
	for <linux-mm@kvack.org>; Sat, 30 May 2009 19:10:01 -0400 (EDT)
Date: Sun, 31 May 2009 00:10:52 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090531001052.40ac57d2@lxorguk.ukuu.org.uk>
In-Reply-To: <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com>
References: <20090528090836.GB6715@elte.hu>
	<20090530075033.GL29711@oblivion.subreption.com>
	<4A20E601.9070405@cs.helsinki.fi>
	<20090530082048.GM29711@oblivion.subreption.com>
	<20090530173428.GA20013@elte.hu>
	<20090530180333.GH6535@oblivion.subreption.com>
	<20090530182113.GA25237@elte.hu>
	<20090530184534.GJ6535@oblivion.subreption.com>
	<20090530190828.GA31199@elte.hu>
	<4A21999E.5050606@redhat.com>
	<84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> It's pretty damn obvious that Larry's patches have a much bigger
> performance impact than using kzfree() for selected parts of the
> kernel. So yes, I do expect him to benchmark and demonstrate that
> kzfree() has _performance problems_ before we can look into merging
> his patches.

We seem to be muddling up multiple things here which is not helpful.

There are three things going on

#1 Is ksize() buggy ?

#2 Using kzfree() to clear specific bits of memory (and I question the
kzfree implementation as it seems ksize can return numbers much much
bigger than the allocated space you need to clear - correct but oversize)
or using other flags. I'd favour kzfree personally (and fixing it to work
properly)

#3 People wanting to be able to select for more security *irrespective*
of performance cost. Which is no different to SELinux for example.


Conflating them all into one mess is causing confusion

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
