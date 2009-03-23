Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B06916B00BD
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 03:52:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N8rpqc016236
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 17:53:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C22A45DD74
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:53:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E179545DD72
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:53:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D67011DB8016
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:53:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 881F01DB8014
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:53:50 +0900 (JST)
Date: Mon, 23 Mar 2009 17:52:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-Id: <20090323175223.94b644a0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323083506.GN24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323052247.GJ24227@balbir.in.ibm.com>
	<20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323151703.de2bf9db.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323083506.GN24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 14:05:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 15:17:03]:
> Kame, if you dislike it please don't enable
> memory.soft_limit_in_bytes. After having sent several revisions of
> your own patchset and helping me with review of several revisions, your
> sudden dislike comes as a surprise.

I can't think
  - we need hook in mem_cgroup_charge/uncharge.
  - RB-tree is good.
  - don't taking care of kswad is enough

and memcg should be independent from global memory reclaim AMAP.

> Please NOTE: I am not saying we'll never see any of the reclaim
> changes you are suggesting, all I am saying is lets do enough test to
> prove it is needed. Lets get the functionality right and then optimize
> if we have to.
> 

But this itself is problem for me.

When we added
  - hierarchy
  - swap handling
  - etc...

Almost all bug reports are from Nishimura and Li Zefan, not from *us*.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
