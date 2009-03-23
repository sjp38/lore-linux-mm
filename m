Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B0526B00B2
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 03:31:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N8WGwM003851
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 17:32:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 97E9F45DD7F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:32:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 67F9B45DD7B
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:32:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 97F2EE08007
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:32:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36EE4E08002
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:32:14 +0900 (JST)
Date: Mon, 23 Mar 2009 17:30:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] Memory controller soft limit reclaim on contention
 (v7)
Message-Id: <20090323173049.fb178a7b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323082822.GM24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165752.27274.36030.sendpatchset@localhost.localdomain>
	<20090320130630.8b9ac3c7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090322142748.GC24227@balbir.in.ibm.com>
	<20090323090205.49fc95d0.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323041253.GH24227@balbir.in.ibm.com>
	<20090323132045.092127da.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323082822.GM24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 13:58:22 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> I've seen it, the basic assumption of the patch is that
> 
> policy_zonelist() and for_each_zone_zonelist_nodemask() where nodemask
> is derived from policy_nodemask() give different results.. correct?
> 

Basic thinking is that there is alloc_pages_nodemask() but try_to_free_pages()
ignores nodemask. Then, removing alloc_pages_nodemask() or taking care of nodemask
in try_to_free_pages() is necessary.

How nodemask/zonelist is built is out of sight.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
