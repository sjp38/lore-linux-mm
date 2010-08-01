Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CF422600429
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 06:51:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o71Ap7BC021694
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 1 Aug 2010 19:51:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 96C6A45DE57
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 19:51:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FB4B45DE52
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 19:51:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DE561DB803F
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 19:51:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C24B41DB803C
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 19:51:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: synchronous lumpy reclaim don't call congestion_wait()
In-Reply-To: <20100801104232.GA17573@localhost>
References: <20100801180751.4B0E.A69D9226@jp.fujitsu.com> <20100801104232.GA17573@localhost>
Message-Id: <20100801194520.4B14.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  1 Aug 2010 19:51:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

> > If the system 512MB memory, DEF_PRIORITY mean 128kB scan and It takes 4096
> > shrink_page_list() calls to scan 128kB (i.e. 128kB/32=4096) memory.
> 
> Err you must forgot the page size.

page size? DEF_PRIORITY is 12.

512MB >> DEF_PRIORITY
 = 512MB / 4096
 = 128kB

128kB scan mean 4096 times shrink_list(). because one shrink_list() scan
SWAP_CLUSTER_MAX (i.e. 32).

> 
> 128kB means 128kB/4kB=32 pages which fit exactly into one
> SWAP_CLUSTER_MAX batch. The shrink_page_list() call times
> has nothing to do DEF_PRIORITY.

Umm.. I haven't catch this mention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
