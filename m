Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 60C576B00FE
	for <linux-mm@kvack.org>; Sat, 30 May 2009 19:12:21 -0400 (EDT)
Date: Sun, 31 May 2009 00:13:18 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090531001318.093e3665@lxorguk.ukuu.org.uk>
In-Reply-To: <20090530213311.GM6535@oblivion.subreption.com>
References: <20090530075033.GL29711@oblivion.subreption.com>
	<4A20E601.9070405@cs.helsinki.fi>
	<20090530082048.GM29711@oblivion.subreption.com>
	<20090530173428.GA20013@elte.hu>
	<20090530180333.GH6535@oblivion.subreption.com>
	<20090530182113.GA25237@elte.hu>
	<20090530184534.GJ6535@oblivion.subreption.com>
	<20090530190828.GA31199@elte.hu>
	<4A21999E.5050606@redhat.com>
	<84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com>
	<20090530213311.GM6535@oblivion.subreption.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> I was pointing out that the 'those test and jump/call branches have
> performance hits' argument, while nonsensical, applies to kzfree and
> with even more negative connotations (deeper call depth, more test
> branches used in ksize and kfree, lack of pointer validation).

But they only apply to kzfree - there isn't a cost to anyone else. You've
move the decision to compile time which for the fast path stuff when you
just want to clear keys and other oddments is a big win.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
