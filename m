Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7F46A6B0093
	for <linux-mm@kvack.org>; Tue, 12 May 2009 11:05:42 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4CEttgZ017607
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:55:55 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4CF5iLe242098
	for <linux-mm@kvack.org>; Tue, 12 May 2009 11:05:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4CF5h96010714
	for <linux-mm@kvack.org>; Tue, 12 May 2009 11:05:44 -0400
Subject: Re: [RFC] Replace the watermark-related union in struct zone with
 awatermark[] array V2
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090512141331.GI25923@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-19-git-send-email-mel@csn.ul.ie>
	 <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com>
	 <20090427170054.GE912@csn.ul.ie>
	 <alpine.DEB.2.00.0904271340320.11972@chino.kir.corp.google.com>
	 <20090427205400.GA23510@csn.ul.ie>
	 <alpine.DEB.2.00.0904271400450.11972@chino.kir.corp.google.com>
	 <20090430133524.GC21997@csn.ul.ie> <1241099300.29485.96.camel@nimitz>
	 <20090512141331.GI25923@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 12 May 2009 08:05:39 -0700
Message-Id: <1242140739.8109.40078.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-05-12 at 15:13 +0100, Mel Gorman wrote:
> Changelog since V1
>   o Use N_wmark_pages accessors instead of array accesses
> 
> Patch page-allocator-use-allocation-flags-as-an-index-to-the-zone-watermark
> from -mm added a union to struct zone where the watermarks could be accessed
> with either zone->pages_* or a pages_mark array. The concern was that this
> aliasing caused more confusion that it helped.
> 
> This patch replaces the union with a watermark array that is indexed with
> WMARK_* defines accessed via helpers. All call sites that use zone->pages_*
> are updated to use the helpers for accessing the values and the array
> offsets for setting.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  Documentation/sysctl/vm.txt |   11 ++++++-----
>  Documentation/vm/balance    |   18 +++++++++---------
>  arch/m32r/mm/discontig.c    |    6 +++---
>  include/linux/mmzone.h      |   20 ++++++++++++++------
>  mm/page_alloc.c             |   41 +++++++++++++++++++++--------------------
>  mm/vmscan.c                 |   39 +++++++++++++++++++++------------------
>  mm/vmstat.c                 |    6 +++---
>  7 files changed, 77 insertions(+), 64 deletions(-)

Looks nice.  It net adds a few lines of code, but that's mostly from the
#defines and not added complexity or lots of line wrapping.  

Ackedf-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
