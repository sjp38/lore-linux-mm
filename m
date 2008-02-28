Date: Wed, 27 Feb 2008 16:08:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [PATCH] mmu notifiers #v7
In-Reply-To: <20080227234317.GM28483@v2.random>
Message-ID: <Pine.LNX.4.64.0802271605480.15667@schroedinger.engr.sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random>
 <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random>
 <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de>
 <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random> <Pine.LNX.4.64.0802271503050.13186@schroedinger.engr.sgi.com>
 <20080227234317.GM28483@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008, Andrea Arcangeli wrote:

> If RDMA/IB folks needed to block in invalidate_range, I guess they
> need to do so on top of tmpfs too, and that never worked with your
> patch anyway.

How about blocking in invalidate_page()? It can be made to work...

> > Would it not be better to have a solution that fits all instead of hacking 
> > something in now and then having to modify it later?
> 
> The whole point is that your solution fits only GRU and KVM too.

Well so we do not address the issues?
 
> XPMEM in your patch works in a hacked mode limited to anonymous memory
> only, Robin already received incoming mail asking to allow xpmem to
> work on more than anonymous memory, so your solution-that-fits-all
> doesn't actually fit some of Robin's customer needs. So if it doesn't
> even entirely satisfy xpmem users, imagine the other potential
> blocking-users of this code.

The solutions have been mentioned...

> anon_vma lock can remain a spinlock unless you also want to schedule
> inside try_to_unmap.

Either that or a separate rmap as also mentioned before.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
