Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 34BE16B0095
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 16:31:04 -0500 (EST)
Date: Thu, 28 Jan 2010 22:31:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP 3/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100128213100.GI1217@random.random>
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
 <20100128195634.798620000@alcatraz.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128195634.798620000@alcatraz.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 01:56:30PM -0600, Robin Holt wrote:
> 
> Make the truncate case handle the need to sleep.  We accomplish this
> by failing the mmu_notifier_invalidate_range_start(... atomic==1)
> case which inturn falls back to unmap_mapping_range_vma() with the
> restart_address == start_address.  In that case, we make an additional
> callout to mmu_notifier_invalidate_range_start(... atomic==0) after the
> i_mmap_lock has been released.

I think this is as dirty as it can be and why Christoph's first
patchset was turned down by Andrew (rightfully). What is wrong with
MMU_NOTIFIER_SLEEPABLE=y that is automatically enabled by XPMEM=y?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
