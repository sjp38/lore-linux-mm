Date: Fri, 1 Feb 2008 17:35:28 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 2/4] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080201233528.GE12099@sgi.com>
References: <20080201050439.009441434@sgi.com> <20080201050623.344041545@sgi.com> <20080201220952.GA3875@sgi.com> <Pine.LNX.4.64.0802011517430.20608@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802011517430.20608@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2008 at 03:19:32PM -0800, Christoph Lameter wrote:
> On Fri, 1 Feb 2008, Robin Holt wrote:
> 
> > We are getting this callout when we transition the pte from a read-only
> > to read-write.  Jack and I can not see a reason we would need that
> > callout.  It is causing problems for xpmem in that a write fault goes
> > to get_user_pages which gets back to do_wp_page that does the callout.
> 
> Right. You placed it there in the first place. So we can drop the code 
> from do_wp_page?

No, we need a callout when we are becoming more restrictive, but not
when becoming more permissive.  I would have to guess that is the case
for any of these callouts.  It is for both GRU and XPMEM.  I would
expect the same is true for KVM, but would like a ruling from Andrea on
that.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
