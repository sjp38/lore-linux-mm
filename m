Date: Wed, 23 Oct 2002 13:50:26 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
Message-ID: <20021023115026.GB30182@dualathlon.random>
References: <20021023020534.GJ11242@dualathlon.random> <Pine.LNX.4.44.0210230851170.2360-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210230851170.2360-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 23, 2002 at 09:19:23AM +0200, Ingo Molnar wrote:
> theory (and i raised that possibility in the discussion), but i'd like to
> see your patch first, because yet another vma tree is quite some
> complexity and it further increases the size of the vma, which is not
> quite a no-cost approach.

it's not another vma tree, furthmore another vma tree indexed by the
hole size wouldn't be able to defragment and it would find the best fit
not the first fit on the left.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
