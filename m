Date: Mon, 3 Mar 2008 11:01:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v8
In-Reply-To: <20080303032934.GA3301@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0803031058230.6917@schroedinger.engr.sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random>
 <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random>
 <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de>
 <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random>
 <20080303032934.GA3301@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Jack Steiner <steiner@sgi.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2008, Nick Piggin wrote:

> I'm still not completely happy with this. I had a very quick look
> at the GRU driver, but I don't see why it can't be implemented
> more like the regular TLB model, and have TLB insertions depend on
> the linux pte, and do invalidates _after_ restricting permissions
> to the pte.
> 
> Ie. I'd still like to get rid of invalidate_range_begin, and get
> rid of invalidate calls from places where permissions are relaxed.

Isnt this more a job for paravirt ops if it is so tightly bound to page 
tables? Are we not adding another similar API?

> If we can agree on the API, then I don't see any reason why it can't
> go into 2.6.25, unless someome wants more time to review it (but
> 2.6.25 release should be quite far away still so there should be quite
> a bit of time).

API still has rcu issues and the example given for making things sleepable 
is only working for the aging callback. The most important callback is for 
try_to_unmao and page_mkclean. This means the API is still not generic 
enough and likely not extendable as needed in its present form.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
