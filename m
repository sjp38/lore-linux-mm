Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 270546B0070
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:55:46 -0400 (EDT)
Date: Tue, 2 Oct 2012 15:55:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/8] THP support for Sparc64
Message-Id: <20121002155544.2c67b1e8.akpm@linux-foundation.org>
In-Reply-To: <20121002.182601.845433592794197720.davem@davemloft.net>
References: <20121002.182601.845433592794197720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, aarcange@redhat.com, hannes@cmpxchg.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Tue, 02 Oct 2012 18:26:01 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> Here is a set of patches that add THP support for sparc64.
> 
> A few of them are relatively minor portability issues I ran into.
> Like the MIPS guys I hit the update_mmu_cache() typing issue so I have
> a patch for that here.
> 
> It is very likely that I need the ACCESSED bit handling fix the
> ARM folks have been posting recently as well.
> 
> On the sparc64 side the biggest issue was moving to only supporting
> 4MB pages and then realigning the page tables so that the PMDs map 4MB
> (instead of 8MB as they do now).
> 
> The rest was just trial and error, running tests, and fixing bugs.
> 
> A familiar test case that makes 5 million random accesses to a 1GB
> memory area goes from 20 seconds down to 0.43 seconds with THP enabled
> on my SPARC T4-2 box.

Hardly worth bothering about ;)

I had a shot at integrating all this onto the pending stuff in linux-next. 
"mm: Add and use update_mmu_cache_pmd() in transparent huge page code."
needed minor massaging in huge_memory.c.  But as Andrea mentioned, we
ran aground on Gerald's
http://ozlabs.org/~akpm/mmotm/broken-out/thp-remove-assumptions-on-pgtable_t-type.patch,
part of the thp-for-s390 work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
