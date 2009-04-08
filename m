Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 842855F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:04:43 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3872qJo004341
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 17:02:52 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3874cZh397482
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 17:04:41 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3874cGj019943
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 17:04:38 +1000
Date: Wed, 8 Apr 2009 12:34:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-ID: <20090408070401.GC7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090407063722.GQ7082@balbir.in.ibm.com> <20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com> <20090407071825.GR7082@balbir.in.ibm.com> <20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com> <20090407080355.GS7082@balbir.in.ibm.com> <20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com> <20090408052904.GY7082@balbir.in.ibm.com> <20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 15:15:29]:

> On Wed, 8 Apr 2009 10:59:04 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> 
> > > no serious intention.
> > > Just because you wrote "expect the user to account all cached pages as shared" ;)
> > >
> > 
> > OK, I noticed another thing, our RSS accounting is not RSS per-se, it
> > includes only anon RSS, file backed pages are accounted as cached.
> > I'll send out a patch to see if we can include anon RSS as well.
> >  
> 
> I think we can't do it in memcg layer without new-hook because file caches
> are added to radix-tree before mapped.
> 
> mm struct has anon_rss and file_rss coutners. Then, you can show
> sum of total maps of file pages. maybe.
>

Yes, correct and that is a hook worth adding, IMHO. Better statistics
are critical and it will also help us with the shared memory
accounting. Without that we can't account for file rss in the memory
cgroup. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
