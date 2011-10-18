Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CE0D26B002D
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 20:46:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2CB3B3EE0C3
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 09:46:56 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B92B45DE9E
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 09:46:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E617E45DEA6
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 09:46:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D9E681DB8038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 09:46:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A40501DB8040
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 09:46:55 +0900 (JST)
Date: Tue, 18 Oct 2011 09:45:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: memory hotplug: Check if pages are correctly
 reserved on a per-section basis
Message-Id: <20111018094559.ff01db54.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111017143820.GA7626@suse.de>
References: <20111010071119.GE6418@suse.de>
	<20111010150038.ac161977.akpm@linux-foundation.org>
	<20111010232403.GA30513@kroah.com>
	<20111010162813.7a470ae4.akpm@linux-foundation.org>
	<20111011072406.GA2503@suse.de>
	<20111017143820.GA7626@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, nfont@linux.vnet.ibm.com, rientjes@google.com

On Mon, 17 Oct 2011 16:38:20 +0200
Mel Gorman <mgorman@suse.de> wrote:

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

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
