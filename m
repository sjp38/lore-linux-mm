Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D57516B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 23:07:26 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7I37OHc031858
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Aug 2010 12:07:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AEF6F45DE4F
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:07:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7225D45DE51
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:07:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 47355E18001
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:07:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BCBEEE08001
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:07:22 +0900 (JST)
Date: Wed, 18 Aug 2010 12:02:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-Id: <20100818120232.a9dc128e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1281951733-29466-4-git-send-email-mel@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 2010 10:42:13 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> When under significant memory pressure, a process enters direct reclaim
> and immediately afterwards tries to allocate a page. If it fails and no
> further progress is made, it's possible the system will go OOM. However,
> on systems with large amounts of memory, it's possible that a significant
> number of pages are on per-cpu lists and inaccessible to the calling
> process. This leads to a process entering direct reclaim more often than
> it should increasing the pressure on the system and compounding the problem.
> 
> This patch notes that if direct reclaim is making progress but
> allocations are still failing that the system is already under heavy
> pressure. In this case, it drains the per-cpu lists and tries the
> allocation a second time before continuing.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
