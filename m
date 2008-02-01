Date: Thu, 31 Jan 2008 20:47:42 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
Message-ID: <20080201024742.GD26420@sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com> <20080201023113.GB26420@sgi.com> <Pine.LNX.4.64.0801311838070.26594@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311838070.26594@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 06:39:19PM -0800, Christoph Lameter wrote:
> On Thu, 31 Jan 2008, Robin Holt wrote:
> 
> > Jack has repeatedly pointed out needing an unregister outside the
> > mmap_sem.  I still don't see the benefit to not having the lock in the mm.
> 
> I never understood why this would be needed. ->release removes the 
> mmu_notifier right now.

Both xpmem and GRU have means of removing their context seperate from
process termination.  XPMEMs is by closing the fd, I believe GRU is
the same.  In the case of XPMEM, we are able to acquire the mmap_sem.
For GRU, I don't think it is possible, but I do not remember the exact
reason.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
