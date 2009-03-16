Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 82FA26B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:04:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2G94VAk031512
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 16 Mar 2009 18:04:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3EC345DD7F
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 18:04:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2D1045DD7B
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 18:04:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3C951DB803E
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 18:04:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61E421DB8041
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 18:04:30 +0900 (JST)
Date: Mon, 16 Mar 2009 18:03:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
Message-Id: <20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain>
	<20090314173111.16591.68465.sendpatchset@localhost.localdomain>
	<20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316083512.GV16897@balbir.in.ibm.com>
	<20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009 17:49:43 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 16 Mar 2009 14:05:12 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> For example, shrink_slab() is not called. and this must be called.
> 
> For exmaple, we may have to add 
>  sc->call_shrink_slab
> flag and set it "true" at soft limit reclaim. 
> 
At least, this check will be necessary in v7, I think.
shrink_slab() should be called.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
