Message-ID: <4354696D.4050101@jp.fujitsu.com>
Date: Tue, 18 Oct 2005 12:18:05 +0900
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
Cc: akpm@osdl.org, linux-mm@kvack.org, ak@suse.de, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi,

Christoph Lameter wrote:

> The disadvantage over direct page migration are:
> 
> A. Performance: Having to go through swap is slower.
> 
> B. The need for swap space: The area to be migrated must fit into swap.
> 
I think migration cache will work well for A & B :)
migraction cache is virtual swap, just unmap a page and modifies it as a swap cache.

> C. Placement of pages at swapin is done under the memory policy in
>    effect at that time. This may destroy nodeset relative positioning.
> 
How about this ?
==
1. do_mbind()
2. unmap and moves to migraction cache
3. touch all pages
==
For 3., 2. should gather all present virtual address list...

D. We need another page-cache migration functions for moving page-cache :(
    Moving just anon is not for memory-hotplug.
    (BTW, how should pages in page cache be affected by memory location control ??
     I think some people discussed about that...)

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
