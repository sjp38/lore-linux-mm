Date: Tue, 18 Oct 2005 09:50:45 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 0/2] Page migration via Swap V2: Overview
In-Reply-To: <43549815.9090001@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.62.0510180948490.7911@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
 <43549815.9090001@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, jschopp@austin.ibm.com, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Oct 2005, KAMEZAWA Hiroyuki wrote:

> Because sys_mbind() acquires mm->mmap_sem, once page is unmapped,
> all accesses to the page are blocked.
> 
> So, even if the range contains hot pages, there will not be
> hard-to-be-swapped-out pages. right ?

There may be locked pages and maybe pages that are continually busy.
 
> sys_mbind() can aquire mm->mmap_sem for migrating *a process's page*,
> but memory-hotplug cannot aquire the lock for migrating a chunk of pages.

I did mbind first because it is the less invasive. The primary reason to 
acquire mmap_sem is to be able to walk the vma areas.

> I think we'll need radix_tree_replace for migating arbitrary chunk of pages,
> anyway.

Likely. Ultimately I would like to see the direct migration work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
