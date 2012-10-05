Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id BEF616B005D
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 18:01:11 -0400 (EDT)
Date: Fri, 5 Oct 2012 15:01:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 5/7] mm: Add and use update_mmu_cache_pmd() in
 transparent huge page code.
Message-Id: <20121005150110.fdf08c96.akpm@linux-foundation.org>
In-Reply-To: <20121004.154738.461031090401264236.davem@davemloft.net>
References: <20121004.154738.461031090401264236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, aarcange@redhat.com, hannes@cmpxchg.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Thu, 04 Oct 2012 15:47:38 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> The transparent huge page code passes a PMD pointer in as the third
> argument of update_mmu_cache(), which expects a PTE pointer.
> 
> This never got noticed because X86 implements update_mmu_cache() as a
> macro and thus we don't get any type checking, and X86 is the only
> architecture which supports transparent huge pages currently.
> 
> Before oter architectures can support transparent huge pages properly
> we need to add a new interface which will take a PMD pointer as the
> third argument rather than a PTE pointer.

I'll toss this on top:

--- a/arch/s390/include/asm/pgtable.h~mm-add-and-use-update_mmu_cache_pmd-in-transparent-huge-page-code-fix
+++ a/arch/s390/include/asm/pgtable.h
@@ -42,6 +42,7 @@ extern void fault_init(void);
  * tables contain all the necessary information.
  */
 #define update_mmu_cache(vma, address, ptep)     do { } while (0)
+#define update_mmu_cache_pmd(vma, address, ptep) do { } while (0)
 
 /*
  * ZERO_PAGE is a global shared page that is always zero; used
_

and I trust that Gerald will be able to review test the result once all
this has landed, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
