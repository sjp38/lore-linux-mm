Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6FBD25F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:40:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n387eqle032119
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Apr 2009 16:40:52 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5198445DE5D
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:40:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E6E045DE51
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:40:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA2361DB803E
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:40:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7877BE38003
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:40:51 +0900 (JST)
Date: Wed, 8 Apr 2009 16:39:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-Id: <20090408163923.a40aad03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090407063722.GQ7082@balbir.in.ibm.com>
	<20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090407071825.GR7082@balbir.in.ibm.com>
	<20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com>
	<20090407080355.GS7082@balbir.in.ibm.com>
	<20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408052904.GY7082@balbir.in.ibm.com>
	<20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408070401.GC7082@balbir.in.ibm.com>
	<20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408071115.GD7082@balbir.in.ibm.com>
	<20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Apr 2009 16:18:24 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 8 Apr 2009 12:41:15 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 16:07:33]:
> > 1. First our rss in memory.stat is confusing, we should call it anon
> > RSS
> ok. but ....changing current interface ?
> 
> > 2. We need to add file rss, this is sort of inline with the
> > information we export per process file_rss and anon_rss
> 
> maybe good. *but* active/incative ratio in lru file cache is good estimation for this.
> 
> > 3. Using the above, we can then try to (using an algorithm you
> > proposed), try to do some work for figuring out the shared percentage.
> > 
> This is the point. At last. Why "# of shared pages" is important ?
> 
> I wonder it's better to add new stat file as memory.cacheinfo which helps
> following kind of commands.
> 
>   #cacheinfo /cgroups/memory/group01/
>        /usr/lib/libc.so.1     30pages
>        /var/log/messages      1 pages
>        /tmp/xxxxxx            20 pages
>        .....
>        .....
To do above, I wonder it's better to add "cache count cgroup" rather than modify memcg.
plz ignore.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
