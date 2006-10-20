Date: Thu, 19 Oct 2006 18:45:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] virtual memmap for sparsemem [2/2] for ia64.
In-Reply-To: <20061020103534.35a92813.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0610191842300.11820@schroedinger.engr.sgi.com>
References: <20061019172328.4bcb1551.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610190940140.8072@schroedinger.engr.sgi.com>
 <20061020103534.35a92813.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Oct 2006, KAMEZAWA Hiroyuki wrote:

> Maximun phyisical address size of Itanium2 looks 50bits. Then, we need
> sizeof (struct page) * (50 - PAGE_SHIFT) size of virtual address space.

Right. That is 4TB which can be a portion of the 128TB VMALLOC space. Have 
you seen my patchset that does the calculation on linux-ia674?

> 
> #ifdef CONFIG_PGTABLE_4
> #define PGDIR_SHIFT             (PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
> #else
> #define PGDIR_SHIFT             (PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
> #endif
> 
> Then, considering PAGE_SHIFT=14 case, 
> 4-level-page-table mapsize:(1 << (4 * PAGE_SHIFT - 9) -> (1 << 47)
> 3-level-page-table mapsize:(1 << (3 * PAGE_SHIFT - 6) -> (1 << 36)

You are missing one PAGE_SHIFT (the page that is referred to !)

3 level is 47. 4 level is 58. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
