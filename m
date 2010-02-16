Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D625C6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 02:05:12 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G75AoI013015
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Feb 2010 16:05:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F1E7D45DE4C
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:05:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D39D545DE51
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:05:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C8C9E08006
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:05:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B21F1DB803F
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 16:05:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 01/12] mm: Document /proc/pagetypeinfo
In-Reply-To: <1265976059-7459-2-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20100216160436.7300.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Feb 2010 16:05:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The memory compaction patches add details to pagetypeinfo that are not
> obvious and need to be documented. In preparation for this, document
> what is already in /proc/pagetypeinfo.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Looks nicer.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> ---
>  Documentation/filesystems/proc.txt |   45 +++++++++++++++++++++++++++++++++++-
>  1 files changed, 44 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 0d07513..1829dfb 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -430,6 +430,7 @@ Table 1-5: Kernel info in /proc
>   modules     List of loaded modules                            
>   mounts      Mounted filesystems                               
>   net         Networking info (see text)                        
> + pagetypeinfo Additional page allocator information (see text)  (2.5)
>   partitions  Table of partitions known to the system           
>   pci	     Deprecated info of PCI bus (new way -> /proc/bus/pci/,
>               decoupled by lspci					(2.4)
> @@ -584,7 +585,7 @@ Node 0, zone      DMA      0      4      5      4      4      3 ...
>  Node 0, zone   Normal      1      0      0      1    101      8 ...
>  Node 0, zone  HighMem      2      0      0      1      1      0 ...
>  
> -Memory fragmentation is a problem under some workloads, and buddyinfo is a 
> +External fragmentation is a problem under some workloads, and buddyinfo is a
>  useful tool for helping diagnose these problems.  Buddyinfo will give you a 
>  clue as to how big an area you can safely allocate, or why a previous
>  allocation failed.
> @@ -594,6 +595,48 @@ available.  In this case, there are 0 chunks of 2^0*PAGE_SIZE available in
>  ZONE_DMA, 4 chunks of 2^1*PAGE_SIZE in ZONE_DMA, 101 chunks of 2^4*PAGE_SIZE 
>  available in ZONE_NORMAL, etc... 
>  
> +More information relevant to external fragmentation can be found in
> +pagetypeinfo.
> +
> +> cat /proc/pagetypeinfo
> +Page block order: 9
> +Pages per block:  512
> +
> +Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
> +Node    0, zone      DMA, type    Unmovable      0      0      0      1      1      1      1      1      1      1      0
> +Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
> +Node    0, zone      DMA, type      Movable      1      1      2      1      2      1      1      0      1      0      2
> +Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      1      0
> +Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> +Node    0, zone    DMA32, type    Unmovable    103     54     77      1      1      1     11      8      7      1      9
> +Node    0, zone    DMA32, type  Reclaimable      0      0      2      1      0      0      0      0      1      0      0
> +Node    0, zone    DMA32, type      Movable    169    152    113     91     77     54     39     13      6      1    452
> +Node    0, zone    DMA32, type      Reserve      1      2      2      2      2      0      1      1      1      1      0
> +Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> +
> +Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate
> +Node 0, zone      DMA            2            0            5            1            0
> +Node 0, zone    DMA32           41            6          967            2            0
> +
> +Fragmentation avoidance in the kernel works by grouping pages of different
> +migrate types into the same contiguous regions of memory called page blocks.
> +A page block is typically the size of the default hugepage size e.g. 2MB on
> +X86-64. By keeping pages grouped based on their ability to move, the kernel
> +can reclaim pages within a page block to satisfy a high-order allocation.
> +
> +The pagetypinfo begins with information on the size of a page block. It
> +then gives the same type of information as buddyinfo except broken down
> +by migrate-type and finishes with details on how many page blocks of each
> +type exist.
> +
> +If min_free_kbytes has been tuned correctly (recommendations made by hugeadm
> +from libhugetlbfs http://sourceforge.net/projects/libhugetlbfs/), one can
> +make an estimate of the likely number of huge pages that can be allocated
> +at a given point in time. All the "Movable" blocks should be allocatable
> +unless memory has been mlock()'d. Some of the Reclaimable blocks should
> +also be allocatable although a lot of filesystem metadata may have to be
> +reclaimed to achieve this.
> +
>  ..............................................................................
>  
>  meminfo:
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
