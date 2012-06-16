Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A0CAC6B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 03:20:54 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 351523EE0AE
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:20:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BF8145DE4D
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:20:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 05A7645DD74
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:20:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDD2D1DB803A
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:20:52 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A61B31DB802C
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:20:52 +0900 (JST)
Message-ID: <4FDC3359.6090204@jp.fujitsu.com>
Date: Sat, 16 Jun 2012 16:18:49 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix page reclaim comment error
References: <1339677662-25942-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <1339677662-25942-1-git-send-email-liwp.linux@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, trivial@kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

(2012/06/14 21:41), Wanpeng Li wrote:
> From: Wanpeng Li<liwp@linux.vnet.ibm.com>
> 
> Since there are five lists in LRU cache, the array nr in get_scan_count
> should be:
> 
> nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
> nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
> 
> Signed-off-by: Wanpeng Li<liwp.linux@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
