Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B82F5F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:05:45 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 06E7C82C962
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 11:20:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IKmO2fKdGcym for <linux-mm@kvack.org>;
	Tue,  2 Jun 2009 11:20:26 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F0B3B82CAC3
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 11:19:52 -0400 (EDT)
Date: Tue, 2 Jun 2009 11:05:09 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Use kzfree in tty buffer management to enforce data
 sanitization
In-Reply-To: <alpine.LFD.2.01.0905311002010.3435@localhost.localdomain>
Message-ID: <alpine.DEB.1.10.0906021103490.23962@gentwo.org>
References: <20090531015537.GA8941@oblivion.subreption.com> <alpine.LFD.2.01.0905301902530.3435@localhost.localdomain> <84144f020905302324r5e342f2dlfd711241ecfc8374@mail.gmail.com> <20090531112630.2c7f4f1d@lxorguk.ukuu.org.uk>
 <alpine.LFD.2.01.0905311002010.3435@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 31 May 2009, Linus Torvalds wrote:

> I suspect the "use page allocator" is historical - ie the tty layer
> originally always did that, and then when people wanted to suppotr smaller
> areas than one page, they added the special case. I have this dim memory
> of the _original_ kmalloc not handling page-sized allocations well (due to
> embedded size/pointer overheads), but I think all current allocators are
> perfectly happy to allocate PAGE_SIZE buffers without slop.
>
> If I'm right, then we could just use kmalloc/kfree unconditionally. Pekka?

Yes. They do that in various ways. SLOB/SLUB will fall back to the
page allocator for large allocation sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
