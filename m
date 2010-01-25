Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 373066B009E
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 14:01:20 -0500 (EST)
Date: Mon, 25 Jan 2010 20:00:52 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] - Fix unmap_vma() bug related to mmu_notifiers
Message-ID: <20100125190052.GF5756@random.random>
References: <20100125174556.GA23003@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100125174556.GA23003@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Jack Steiner <steiner@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 11:45:56AM -0600, Jack Steiner wrote:
> unmap_vmas() can fail to correctly flush the TLB if a
> callout to mmu_notifier_invalidate_range_start() sleeps.

Not sure I understand: the callbacks invoked by
mmu_notifier_invalidate_range_start can't sleep, or rcu locking inside
mmu notifier will break too (first thing that should be replaced with
srcu if they were allowed to sleep).

In short there's no schedule that could be added because of those
callbacks so if this code isn't ok and schedules and screw on the
mmu_gather tlb it's probably not mmu notifier related.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
