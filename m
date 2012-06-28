Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id BBE316B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 03:13:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 47C873EE0BB
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:13:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F0CED45DE56
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:13:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D7E0D45DE53
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:13:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C11751DB803F
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:13:36 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7008A1DB803A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:13:36 +0900 (JST)
Message-ID: <4FEC039A.5060506@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 16:11:22 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 v2] mm: Factor out memory isolate functions
References: <1340783514-8150-1-git-send-email-minchan@kernel.org> <1340783514-8150-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1340783514-8150-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Marek Szyprowski <m.szyprowski@samsung.com>

(2012/06/27 16:51), Minchan Kim wrote:
> Now mm/page_alloc.c has some memory isolation functions but they
> are used oly when we enable CONFIG_{CMA|MEMORY_HOTPLUG|MEMORY_FAILURE}.
> So let's make it configurable by new CONFIG_MEMORY_ISOLATION so that it
> can reduce binary size and we can check it simple by
> CONFIG_MEMORY_ISOLATION,
> not if defined CONFIG_{CMA|MEMORY_HOTPLUG|MEMORY_FAILURE}.
> 
> This patch is based on next-20120626
> 
> * from v1
>   - rebase on next-20120626
> 
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
