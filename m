Date: Wed, 23 Oct 2002 16:20:30 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
In-Reply-To: <20021023115026.GB30182@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0210231618150.10431-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Oct 2002, Andrea Arcangeli wrote:

> it's not another vma tree, furthmore another vma tree indexed by the
> hole size wouldn't be able to defragment and it would find the best fit
> not the first fit on the left.

what i was talking about was a hole-tree indexed by the hole start
address, not a vma tree indexed by the hole size. (the later is pretty
pointless.) And even this solution still has to search the tree linearly
for a matching hole.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
