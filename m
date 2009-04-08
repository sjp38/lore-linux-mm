Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7EC945F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:09:01 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n38797tC029625
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Apr 2009 16:09:07 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A4AF2AEA81
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:09:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F26C45DD72
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:09:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E2859E38002
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:09:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CB1231DB8041
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:09:01 +0900 (JST)
Date: Wed, 8 Apr 2009 16:07:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-Id: <20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090408070401.GC7082@balbir.in.ibm.com>
References: <20090407063722.GQ7082@balbir.in.ibm.com>
	<20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090407071825.GR7082@balbir.in.ibm.com>
	<20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com>
	<20090407080355.GS7082@balbir.in.ibm.com>
	<20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408052904.GY7082@balbir.in.ibm.com>
	<20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408070401.GC7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Apr 2009 12:34:01 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 15:15:29]:
> 
> > On Wed, 8 Apr 2009 10:59:04 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > 
> > > > no serious intention.
> > > > Just because you wrote "expect the user to account all cached pages as shared" ;)
> > > >
> > > 
> > > OK, I noticed another thing, our RSS accounting is not RSS per-se, it
> > > includes only anon RSS, file backed pages are accounted as cached.
> > > I'll send out a patch to see if we can include anon RSS as well.
> > >  
> > 
> > I think we can't do it in memcg layer without new-hook because file caches
> > are added to radix-tree before mapped.
> > 
> > mm struct has anon_rss and file_rss coutners. Then, you can show
> > sum of total maps of file pages. maybe.
> >
> 
> Yes, correct and that is a hook worth adding, IMHO. Better statistics
> are critical and it will also help us with the shared memory
> accounting. Without that we can't account for file rss in the memory
> cgroup. 
> 
Finally, you'll be asked  "is it necessary ?", if the cost is big.
>From my point of view, I can't see what new information it will give us.
But maybe useful because the user can avoid some calculation.

Cheers,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
