Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 69B4D6B0106
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 03:22:20 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D7MIQ7032505
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 16:22:18 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 075AF45DE54
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:22:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C0E7045DE59
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:22:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6637EE38001
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:22:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A93021DB801A
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:22:16 +0900 (JST)
Date: Wed, 13 Oct 2010 16:16:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when
 per cpu page cache flushed
Message-Id: <20101013161656.9f8b801f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101013160640.ADC9.A69D9226@jp.fujitsu.com>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com>
	<20101013151723.ADBD.A69D9226@jp.fujitsu.com>
	<20101013160640.ADC9.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010 16:10:43 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> When memory shortage, we are using drain_pages() for flushing per cpu
> page cache. In this case, per cpu stat should be flushed too. because
> now we are under memory shortage and we need to know exact free pages.
> 
> Otherwise get_page_from_freelist() may fail even though pcp was flushed.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But it seems performance measurement is necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
