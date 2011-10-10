Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D9D066B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 18:00:43 -0400 (EDT)
Received: by gya6 with SMTP id 6so7865903gya.14
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 15:00:42 -0700 (PDT)
Date: Mon, 10 Oct 2011 15:00:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memory hotplug: Check if pages are correctly
 reserved on a per-section basis
Message-Id: <20111010150038.ac161977.akpm@linux-foundation.org>
In-Reply-To: <20111010071119.GE6418@suse.de>
References: <20111010071119.GE6418@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, nfont@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg KH <greg@kroah.com>

On Mon, 10 Oct 2011 08:11:19 +0100
Mel Gorman <mgorman@suse.de> wrote:

> It is expected that memory being brought online is PageReserved
> similar to what happens when the page allocator is being brought up.
> Memory is onlined in "memory blocks" which consist of one or more
> sections. Unfortunately, the code that verifies PageReserved is
> currently assuming that the memmap backing all these pages is virtually
> contiguous which is only the case when CONFIG_SPARSEMEM_VMEMMAP is set.
> As a result, memory hot-add is failing on !VMEMMAP configurations
> with the message;
> 
> kernel: section number XXX page number 256 not reserved, was it already online?
> 
> This patch updates the PageReserved check to lookup struct page once
> per section to guarantee the correct struct page is being checked.
> 

Nathan's earlier version of this patch is already in linux-next, via
Greg.  We should drop the old version and get the new one merged
instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
