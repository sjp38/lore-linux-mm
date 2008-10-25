Subject: Re: 2.6.28-rc1: EIP: slab_destroy+0x84/0x142
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20081025002406.GA20024@x200.localdomain>
References: <alpine.LFD.2.00.0810232028500.3287@nehalem.linux-foundation.org>
	 <20081024185952.GA18526@x200.localdomain> <1224884318.3248.54.camel@calx>
	 <20081024220750.GA22973@x200.localdomain>
	 <Pine.LNX.4.64.0810241829140.25302@quilx.com>
	 <20081025002406.GA20024@x200.localdomain>
Content-Type: text/plain
Date: Fri, 24 Oct 2008 19:30:30 -0500
Message-Id: <1224894630.3248.77.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, 2008-10-25 at 04:24 +0400, Alexey Dobriyan wrote:
> On Fri, Oct 24, 2008 at 06:29:47PM -0500, Christoph Lameter wrote:
> > On Sat, 25 Oct 2008, Alexey Dobriyan wrote:
> >
> >> Fault occured at slab_destroy in KVM guest kernel.
> >
> > Please switch on all SLAB debug options and rerun.
> 
> They're already on!
> 
> New knowledge: turning off just DEBUG_PAGEALLOC makes oops dissapear,
> other debugging options don't matter.

It's quite possible there's a bad interaction with DEBUG_PAGEALLOC and
the slab redzone logic. The first makes allocations full pages so that
we can later unmap them and detect spurious writes to them while the
second puts a redzone in front of the page (ie potentially in lala
land).

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
