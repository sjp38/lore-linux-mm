Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4176C6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 09:14:51 -0500 (EST)
Date: Mon, 7 Jan 2013 14:14:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-ID: <20130107141446.GF3885@suse.de>
References: <E1Tr9P7-0001AN-S4@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <E1Tr9P7-0001AN-S4@eag09.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, avi@redhat.com, hughd@google.com, linux-mm@kvack.org

On Fri, Jan 04, 2013 at 09:41:53AM -0600, Cliff Wickman wrote:
> From: Cliff Wickman <cpw@sgi.com>
> 
> Avi, Andrea, Andrew, Hugh, Mel,
> 
> We at SGI have a need to address some very high physical address ranges with
> our GRU (global reference unit), sometimes across partitioned machine boundaries
> and sometimes with larger addresses than the cpu supports.
> We do this with the aid of our own 'extended vma' module which mimics the vma.
> When something (either unmap or exit) frees an 'extended vma' we use the mmu
> notifiers to clean them up.
> 
> We had been able to mimic the functions __mmu_notifier_invalidate_range_start()
> and __mmu_notifier_invalidate_range_end() by locking the per-mm lock and 
> walking the per-mm notifier list.  But with the change to a global srcu
> lock (static in mmu_notifier.c) we can no longer do that.  Our module has
> no access to that lock.
> 
> So we request that these two functions be exported.
> 

I do not believe I wrote any of the MMU notifier code so it's not up to
me how it should be exported (or if it should even be allowed). I find it
curious that it appears that no other driver needs this and wonder if you
could also abuse the vma_ops->close interface to do some of the cleanup
but I've no idea what your module is doing. I've no objection to the
export as such but it's really not my call.

Andrea?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
