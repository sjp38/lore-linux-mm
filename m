Message-ID: <43549815.9090001@jp.fujitsu.com>
Date: Tue, 18 Oct 2005 15:37:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] Page migration via Swap V2: Overview
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, jschopp@austin.ibm.com, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi,
Christoph Lameter wrote:
> The patchset consists of two patches:
> 
> 1. Page eviction patch
> 
> Modifies mm/vmscan.c to add functions to isolate pages from the LRU lists,
> swapout lists of pages and return pages to the LRU lists.
> 
> 2. MPOL_MF_MOVE flag for memory policies.
> 
> This implements MPOL_MF_MOVE in addition to MPOL_MF_STRICT. MPOL_MF_STRICT
> allows the checking if all pages in a memory area obey the memory policies.
> MPOL_MF_MOVE will evict all pages that do not conform to the memory policy.
> The system will allocate pages conforming to the policy on swap in.
> 

Because sys_mbind() acquires mm->mmap_sem, once page is unmapped,
all accesses to the page are blocked.

So, even if the range contains hot pages, there will not be
hard-to-be-swapped-out pages. right ?

sys_mbind() can aquire mm->mmap_sem for migrating *a process's page*,
but memory-hotplug cannot aquire the lock for migrating a chunk of pages.

I think we'll need radix_tree_replace for migating arbitrary chunk of pages, anyway.

Thanks,
-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
