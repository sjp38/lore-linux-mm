Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 7B6856B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 22:22:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8D75B3EE0BC
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:22:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7126B45DEAD
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:22:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5975545DEA6
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:22:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 496121DB8038
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:22:33 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F078B1DB8044
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:22:32 +0900 (JST)
Message-ID: <4FD94A6E.3050906@jp.fujitsu.com>
Date: Thu, 14 Jun 2012 11:20:30 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2][BUGFIX] mm: do not use page_count without a page
 pin
References: <1339636334-9238-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1339636334-9238-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Wanpeng Li <liwp.linux@gmail.com>

(2012/06/14 10:12), Minchan Kim wrote:
> d179e84ba fixed the problem[1] in vmscan.c but same problem is here.
> Let's fix it.
> 
> [1] http://comments.gmane.org/gmane.linux.kernel.mm/65844
> 
> I copy and paste d179e84ba's contents for description.
> 
> "It is unsafe to run page_count during the physical pfn scan because
> compound_head could trip on a dangling pointer when reading
> page->first_page if the compound page is being freed by another CPU."
> 
> * changelog from v1
>    - Add comment about skip tail page of THP - Andrea
>    - fix typo - Wanpeng Li
>    - based on next-20120613
> 
> Cc: Andrea Arcangeli<aarcange@redhat.com>
> Cc: Mel Gorman<mgorman@suse.de>
> Cc: Michal Hocko<mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Wanpeng Li<liwp.linux@gmail.com>
> Signed-off-by: Minchan Kim<minchan@kernel.org>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
