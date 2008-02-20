Date: Wed, 20 Feb 2008 03:00:36 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps
	(f.e. for XPmem)
Message-ID: <20080220090035.GG11391@sgi.com>
References: <20080215064859.384203497@sgi.com> <200802201055.21343.nickpiggin@yahoo.com.au> <20080220031221.GE11391@sgi.com> <200802201451.46069.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200802201451.46069.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 02:51:45PM +1100, Nick Piggin wrote:
> On Wednesday 20 February 2008 14:12, Robin Holt wrote:
> > For XPMEM, we do not currently allow file backed
> > mapping pages from being exported so we should never reach this condition.
> > It has been an issue since day 1.  We have operated with that assumption
> > for 6 years and have not had issues with that assumption.  The user of
> > xpmem is MPT and it controls the communication buffers so it is reasonable
> > to expect this type of behavior.
> 
> OK, that makes things simpler.
> 
> So why can't you export a device from your xpmem driver, which
> can be mmap()ed to give out "anonymous" memory pages to be used
> for these communication buffers?

Because we need to have heap and stack available as well.  MPT does
not control all the communication buffer areas.  I haven't checked, but
this is the same problem that IB will have.  I believe they are actually
allowing any memory region be accessible, but I am not sure of that.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
