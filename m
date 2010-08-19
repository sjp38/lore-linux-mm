Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2E9F76B01F6
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:54:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7JNs6GM028552
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 20 Aug 2010 08:54:06 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 448B945DE51
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:54:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 23C1E45DE4E
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:54:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D6671DB803C
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:54:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF45D1DB8038
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:54:05 +0900 (JST)
Date: Fri, 20 Aug 2010 08:49:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-Id: <20100820084908.10e55b76.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008191359400.1839@router.home>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-3-git-send-email-mel@csn.ul.ie>
	<20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008181050230.4025@router.home>
	<20100819090740.3f46aecf.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008191359400.1839@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010 14:00:44 -0500 (CDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> n Thu, 19 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > > This function is now called only at CPU_DEAD. IOW, not called at CPU_UP_PREPARE
> > >
> > > calculate_threshold() does its calculation based on the number of online
> > > cpus. Therefore the threshold may change if a cpu is brought down.
> > >
> > yes. but why not calculate at bringing up ?
> 
> True. Seems to have gone missing somehow.
> 
ok, thank you for checking. I'll prepare a patch.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
