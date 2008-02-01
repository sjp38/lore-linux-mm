Date: Thu, 31 Jan 2008 20:23:22 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080201022321.GZ26420@sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random> <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com> <20080131232842.GQ7185@v2.random> <Pine.LNX.4.64.0801311733140.24297@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311733140.24297@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 05:37:21PM -0800, Christoph Lameter wrote:
> On Fri, 1 Feb 2008, Andrea Arcangeli wrote:
> 
> > I appreciate the review! I hope my entirely bug free and
> > strightforward #v5 will strongly increase the probability of getting
> > this in sooner than later. If something else it shows the approach I
> > prefer to cover GRU/KVM 100%, leaving the overkill mutex locking
> > requirements only to the mmu notifier users that can't deal with the
> > scalar and finegrined and already-taken/trashed PT lock.
> 
> Mutex locking? Could you be more specific?

I think he is talking about the external locking that xpmem will need
to do to ensure we are not able to refault pages inside of regions that
are undergoing recall/page table clearing.  At least that has been my
understanding to this point.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
