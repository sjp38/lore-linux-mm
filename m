Date: Thu, 31 Jan 2008 22:15:13 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
Message-ID: <20080201041512.GF26420@sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com> <20080201035249.GE26420@sgi.com> <Pine.LNX.4.64.0801311957250.17649@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311957250.17649@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 07:58:40PM -0800, Christoph Lameter wrote:
> On Thu, 31 Jan 2008, Robin Holt wrote:
> 
> > > +	void (*invalidate_range_end)(struct mmu_notifier *mn,
> > > +				 struct mm_struct *mm, int atomic);
> > 
> > I think we need to pass in the same start-end here as well.  Without it,
> > the first invalidate_range would have to block faulting for all addresses
> > and would need to remain blocked until the last invalidate_range has
> > completed.  While this would work, (and will probably be how we implement
> > it for the short term), it is far from ideal.
> 
> Ok. Andrea wanted the same because then he can void the begin callouts.
> 
> The problem is that you would have to track the start-end addres right?

Yep.  We will probably no do that in the next week, but I would expect
we have that working before we submit xpmem again.  We will probably
just chain them up in a regular linked list.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
