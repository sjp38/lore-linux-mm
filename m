Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 8A3876B00EA
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 22:00:30 -0400 (EDT)
Date: Wed, 03 Oct 2012 22:00:27 -0400 (EDT)
Message-Id: <20121003.220027.1636081487098835868.davem@davemloft.net>
Subject: Re: [PATCH 0/8] THP support for Sparc64
From: David Miller <davem@davemloft.net>
In-Reply-To: <20121002155544.2c67b1e8.akpm@linux-foundation.org>
References: <20121002.182601.845433592794197720.davem@davemloft.net>
	<20121002155544.2c67b1e8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, aarcange@redhat.com, hannes@cmpxchg.org, gerald.schaefer@de.ibm.com

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 2 Oct 2012 15:55:44 -0700

> I had a shot at integrating all this onto the pending stuff in linux-next. 
> "mm: Add and use update_mmu_cache_pmd() in transparent huge page code."
> needed minor massaging in huge_memory.c.  But as Andrea mentioned, we
> ran aground on Gerald's
> http://ozlabs.org/~akpm/mmotm/broken-out/thp-remove-assumptions-on-pgtable_t-type.patch,
> part of the thp-for-s390 work.

While working on a rebase relative to this work, I noticed that the
s390 patches don't even compile.

It's because of that pmd_pgprot() change from Peter Z. which arrives
asynchonously via the linux-next tree.  It makes THP start using
pmd_pgprot() (a new interface) which the s390 patches don't provide.

It's going to require that I do new work for my sparc64 THP changes as
well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
