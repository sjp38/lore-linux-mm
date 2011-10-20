Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A73686B002D
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 01:20:04 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p9K5JuaF015519
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:20:00 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz5.hot.corp.google.com with ESMTP id p9K5GTEG024506
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:19:54 -0700
Received: by pzk2 with SMTP id 2so8875482pzk.8
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:19:54 -0700 (PDT)
Date: Wed, 19 Oct 2011 22:19:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: memory hotplug: Check if pages are correctly reserved
 on a per-section basis
In-Reply-To: <20111017143820.GA7626@suse.de>
Message-ID: <alpine.DEB.2.00.1110192219390.4618@chino.kir.corp.google.com>
References: <20111010071119.GE6418@suse.de> <20111010150038.ac161977.akpm@linux-foundation.org> <20111010232403.GA30513@kroah.com> <20111010162813.7a470ae4.akpm@linux-foundation.org> <20111011072406.GA2503@suse.de> <20111017143820.GA7626@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, nfont@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 17 Oct 2011, Mel Gorman wrote:

> (Resending as I am not seeing it in -next so maybe it got lost)
> 
> mm: memory hotplug: Check if pages are correctly reserved on a per-section basis
> 
> It is expected that memory being brought online is PageReserved
> similar to what happens when the page allocator is being brought up.
> Memory is onlined in "memory blocks" which consist of one or more
> sections. Unfortunately, the code that verifies PageReserved is
> currently assuming that the memmap backing all these pages is virtually
> contiguous which is only the case when CONFIG_SPARSEMEM_VMEMMAP is set.
> As a result, memory hot-add is failing on those configurations with
> the message;
> 
> kernel: section number XXX page number 256 not reserved, was it already online?
> 
> This patch updates the PageReserved check to lookup struct page once
> per section to guarantee the correct struct page is being checked.
> 
> [Check pages within sections properly: rientjes@google.com]
> [original patch by: nfont@linux.vnet.ibm.com]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
