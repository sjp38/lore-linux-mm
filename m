Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0F9AC6B005D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:28:40 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so2339548pbc.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:28:39 -0800 (PST)
Date: Fri, 16 Nov 2012 11:28:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] thp: fix update_mmu_cache_pmd() calls
In-Reply-To: <1353059717-9850-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211161126450.2788@chino.kir.corp.google.com>
References: <1353059717-9850-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Fri, 16 Nov 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> update_mmu_cache_pmd() takes pointer to pmd_t as third, not pmd_t.
> 
> mm/huge_memory.c: In function 'do_huge_pmd_numa_page':
> mm/huge_memory.c:825:2: error: incompatible type for argument 3 of 'update_mmu_cache_pmd'
> In file included from include/linux/mm.h:44:0,
>                  from mm/huge_memory.c:8:
> arch/mips/include/asm/pgtable.h:385:20: note: expected 'struct pmd_t *' but argument is of type 'pmd_t'
> mm/huge_memory.c:895:2: error: incompatible type for argument 3 of 'update_mmu_cache_pmd'
> In file included from include/linux/mm.h:44:0,
>                  from mm/huge_memory.c:8:
> arch/mips/include/asm/pgtable.h:385:20: note: expected 'struct pmd_t *' but argument is of type 'pmd_t'
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

[routing to Ingo for numa/core, which this is based on]

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
