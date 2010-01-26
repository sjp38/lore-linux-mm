Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0669D6B00AA
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 16:38:58 -0500 (EST)
Date: Tue, 26 Jan 2010 22:38:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] - Fix unmap_vma() bug related to mmu_notifiers
Message-ID: <20100126213853.GY30452@random.random>
References: <20100125174556.GA23003@sgi.com>
 <20100125190052.GF5756@random.random>
 <20100125211033.GA24272@sgi.com>
 <20100125211615.GH5756@random.random>
 <20100126212904.GE6653@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126212904.GE6653@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, cl@linux-foundation.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 03:29:04PM -0600, Robin Holt wrote:
> On Mon, Jan 25, 2010 at 10:16:15PM +0100, Andrea Arcangeli wrote:
> > The old patches are in my ftp area, they should still apply, you
> > should concentrate testing with those additional ones applied, then it
> > will work for xpmem too ;)
> 
> Andrea, could you point me at your ftp area?

Sure, this is the very latest version I maintained:

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.26-rc7/mmu-notifier-v18/

Note, it may be an option to make mmu notifier sleepable through
.config, unless people uses xpmem there is no reason to add
refcounting to vmas. That is something we'd pay even if no KVM is used
and no mmu notifer is used. I think the ideal is that anon-vma lock
should be a rwspinlock and only rcu (no refcounting) with
MMU_NOTIFIER_SLEEPABLE=n, and a read-write sem + refcounting if
MMU_NOTIFIER_SLEEPABLE=y. MMU_NOTIFIER_SLEEPABLE doesn't need to be
user visible, simply XPMEM=y will automatically set
MMU_NOTIFIER_SLEEPABLE=y.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
