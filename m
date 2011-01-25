Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 992A46B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:50:14 -0500 (EST)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Phpq2-0003yG-0l
	for linux-mm@kvack.org; Tue, 25 Jan 2011 21:50:06 +0100
Received: from jfdmzpr02-ext.jf.intel.com ([134.134.137.71])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 25 Jan 2011 21:50:06 +0100
Received: from ak by jfdmzpr02-ext.jf.intel.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 25 Jan 2011 21:50:06 +0100
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 00/25] mm: Preemptibility -v7
Date: Tue, 25 Jan 2011 11:45:28 -0800
Message-ID: <m2ipxcsr6v.fsf@linux.intel.com>
References: <20110125173111.720927511@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <a.p.zijlstra@chello.nl> writes:

> This patch-set makes part of the mm a lot more preemptible. It converts
> i_mmap_lock and anon_vma->lock to mutexes and makes mmu_gather fully
> preemptible.
>
> The main motivation was making mm_take_all_locks() preemptible, since it
> appears people are nesting hundreds of spinlocks there.

Just curious: why is mm_take_all_locks() a problem? As far as I can see
it's just used when starting KVM or GRU the first time. Is that a common
situation?

-Andi

-- 
Andi Kleen
Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
