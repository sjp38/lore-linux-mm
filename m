Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 6A2FA6B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 03:55:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B75063EE0B6
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:55:11 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 952C045DE50
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:55:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D21545DE4E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:55:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F39FE18003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:55:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A3EE1DB8037
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:55:11 +0900 (JST)
Message-ID: <4F829575.4020704@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 16:53:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] huge-memory: Use fast mm counters for transparent
 huge pages
References: <1333202997-19550-1-git-send-email-andi@firstfloor.org> <1333202997-19550-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1333202997-19550-3-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tim.c.chen@linux.intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, aarcange@redhat.com

(2012/03/31 23:09), Andi Kleen wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> We found that the mm struct anon page counter cache line is much hotter
> with transparent huge pages compared to small pages.
> 
> Small pages use a special fast counter mechanism in task_struct, but huge pages
> didn't.  The huge pages are larger than the normal 64 entry threshold for the
> fast counter, so it cannot be directly used. Use a new special counter for huge
> pages to handle them efficiently.
> 
> Any users just calculate the correct total.
> 
> The only special case is transferring the large page count to small pages
> when splitting. I put it somewhat arbitarily into the tricky split
> sequence. Some review on this part is appreciated.
> 
> [An alternative would be to not do that, but that could lead to
> negative counters. These should still give the correct result]
> 
> Contains a fix for a problem found by Andrea in review.
> 
> Cc: aarcange@redhat.com
> Signed-off-by: Andi Kleen <ak@linux.intel.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
