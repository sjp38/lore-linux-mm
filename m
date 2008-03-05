Date: Wed, 5 Mar 2008 01:37:22 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mmu notifiers #v8
Message-ID: <20080305003722.GG1510@wotan.suse.de>
References: <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random> <20080303032934.GA3301@wotan.suse.de> <Pine.LNX.4.64.0803031058230.6917@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031058230.6917@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Jack Steiner <steiner@sgi.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Mon, Mar 03, 2008 at 11:01:22AM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> > I'm still not completely happy with this. I had a very quick look
> > at the GRU driver, but I don't see why it can't be implemented
> > more like the regular TLB model, and have TLB insertions depend on
> > the linux pte, and do invalidates _after_ restricting permissions
> > to the pte.
> > 
> > Ie. I'd still like to get rid of invalidate_range_begin, and get
> > rid of invalidate calls from places where permissions are relaxed.
> 
> Isnt this more a job for paravirt ops if it is so tightly bound to page 
> tables? Are we not adding another similar API?

Um, it's bound to the *Linux page tables*, yes. And I have no idea why
you would use the paravirt ops for this.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
