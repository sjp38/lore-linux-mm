Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6986B0055
	for <linux-mm@kvack.org>; Sun, 31 May 2009 13:09:04 -0400 (EDT)
Date: Sun, 31 May 2009 18:10:20 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Use kzfree in tty buffer management to enforce data
 sanitization
Message-ID: <20090531181020.05fb89d5@lxorguk.ukuu.org.uk>
In-Reply-To: <alpine.LFD.2.01.0905311002010.3435@localhost.localdomain>
References: <20090531015537.GA8941@oblivion.subreption.com>
	<alpine.LFD.2.01.0905301902530.3435@localhost.localdomain>
	<84144f020905302324r5e342f2dlfd711241ecfc8374@mail.gmail.com>
	<20090531112630.2c7f4f1d@lxorguk.ukuu.org.uk>
	<alpine.LFD.2.01.0905311002010.3435@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> I think Pekka meant the other way around - why don't we always just use 
> kmalloc(N_TTY_BUF_SIZE)/kfree(), and drop the whole conditional "use page 
> allocator" entirely?

We certainly can nowdays - the old allocator used to allocate 8K for 4K
and a bit of memory and its many years single we acquired slab so yes it
can go.

> If I'm right, then we could just use kmalloc/kfree unconditionally. Pekka?

Added to the tty queue will do that tomorrow

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
