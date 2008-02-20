Date: Wed, 20 Feb 2008 16:34:09 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v6
Message-ID: <20080220153409.GA7128@v2.random>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080220144155.GI11391@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080220144155.GI11391@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 08:41:55AM -0600, Robin Holt wrote:
> On Wed, Feb 20, 2008 at 11:39:42AM +0100, Andrea Arcangeli wrote:
> > XPMEM simply can't use RCU for the registration locking if it wants to
> > schedule inside the mmu notifier calls. So I guess it's better to add
> 
> Whoa there.  In Christoph's patch, we did not use rcu for the list.  It
> was a simple hlist_head.  The list manipulations were done under
> down_write(&current->mm->mmap_sem) and would therefore not be racy.  All
> the callout locations are already acquiring the mmap_sem at least
> readably, so we should be safe.  Maybe I missed a race somewhere.

You missed quite a few, see when atomic=1 and when mmu_rmap_notifier
is invoked for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
