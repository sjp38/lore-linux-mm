Date: Thu, 31 Jan 2008 19:58:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
In-Reply-To: <20080201035249.GE26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0801311957250.17649@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com>
 <20080201035249.GE26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Robin Holt wrote:

> > +	void (*invalidate_range_end)(struct mmu_notifier *mn,
> > +				 struct mm_struct *mm, int atomic);
> 
> I think we need to pass in the same start-end here as well.  Without it,
> the first invalidate_range would have to block faulting for all addresses
> and would need to remain blocked until the last invalidate_range has
> completed.  While this would work, (and will probably be how we implement
> it for the short term), it is far from ideal.

Ok. Andrea wanted the same because then he can void the begin callouts.

The problem is that you would have to track the start-end addres right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
