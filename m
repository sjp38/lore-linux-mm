Date: Mon, 25 Sep 2000 15:30:50 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925153050.C22882@athlon.random>
References: <20000925150858.A22882@athlon.random> <Pine.LNX.4.21.0009251511050.6224-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251511050.6224-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 03:12:58PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 03:12:58PM +0200, Ingo Molnar wrote:
> well, i think all kernel-space allocations have to be limited carefully,

When a machine without a gigabit ethernet runs oom it's userspace that
allocated the memory via page faults not the kernel.

And if the careful limit avoids the deadlock in the layer above alloc_pages,
then it will also avoid alloc_pages to return NULL and you won't need an
infinite loop in first place (unless the memory balancing is buggy).

GFP should return NULL only if the machine is out of memory. The kernel can be
written in a way that never deadlocks when the machine is out of memory just
checking the GFP retval. I don't think any in-kernel resource limit is
necessary to have things reliable and fast. Most dynamic big caches and kernel
data can be shrinked dynamically during memory pressure (pheraps except skbs
and I agree that for skbs on gigabit ethernet the thing is a little different).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
