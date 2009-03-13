Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C77C76B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:02:26 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D72OR6001886
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Mar 2009 16:02:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B33F45DD7D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:02:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6806045DD7B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:02:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FED21DB8043
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:02:24 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C89BE08002
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:02:21 +0900 (JST)
Message-ID: <7c3bfaf94080838cb7c2f7c54959a9f1.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
Date: Fri, 13 Mar 2009 16:02:20 +0900 (JST)
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v5)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh さんは書きました：
>
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>
> New Feature: Soft limits for memory resource controller.
>
> Changelog v5...v4
> 1. Several changes to the reclaim logic, please see the patch 4 (reclaim
> on
>    contention). I've experimented with several possibilities for reclaim
>    and chose to come back to this due to the excellent behaviour seen
> while
>    testing the patchset.
> 2. Reduced the overhead of soft limits on resource counters very
> significantly.
>    Reaim benchmark now shows almost no drop in performance.
>
It seems there are no changes to answer my last comments.

Nack again. I'll update my own version again.

Thanks,
-Kame

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
