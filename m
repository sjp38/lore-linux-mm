Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED4C6B00FE
	for <linux-mm@kvack.org>; Sat, 30 May 2009 19:14:50 -0400 (EDT)
Date: Sun, 31 May 2009 00:15:48 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090531001548.571d7b59@lxorguk.ukuu.org.uk>
In-Reply-To: <20090530221024.GA23204@elte.hu>
References: <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com>
	<20090530075033.GL29711@oblivion.subreption.com>
	<4A20E601.9070405@cs.helsinki.fi>
	<20090530082048.GM29711@oblivion.subreption.com>
	<20090530173428.GA20013@elte.hu>
	<20090530180333.GH6535@oblivion.subreption.com>
	<20090530182113.GA25237@elte.hu>
	<20090530184534.GJ6535@oblivion.subreption.com>
	<20090530190828.GA31199@elte.hu>
	<4A21999E.5050606@redhat.com>
	<20090530221024.GA23204@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@redhat.com>, "Larry H." <research@subreption.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Obviously the argument is best settled by measurements. Done by 
> whoever wants to push this code.

How do you measure security as a mathematical quantity in a benchtest ?

In terms of performance its pretty easy to stick a counter in kzfree in
2.6.30-rc. The number that comes up is very very low.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
