Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBA34FBZ012017
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 12:04:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E988E45DD80
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 12:04:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C257B45DD7D
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 12:04:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA3691DB803E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 12:04:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 540791DB8042
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 12:04:11 +0900 (JST)
Date: Wed, 10 Dec 2008 12:03:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/6] Flat hierarchical reclaim by ID
Message-Id: <20081210120317.5dce40fa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081210024929.GG7593@balbir.in.ibm.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	<20081209200915.41917722.kamezawa.hiroyu@jp.fujitsu.com>
	<20081209122731.GB4174@balbir.in.ibm.com>
	<3526.10.75.179.61.1228832912.squirrel@webmail-b.css.fujitsu.com>
	<20081209154612.GB7694@balbir.in.ibm.com>
	<36125.10.75.179.61.1228840454.squirrel@webmail-b.css.fujitsu.com>
	<20081210024929.GG7593@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 08:19:29 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > >> >From implementation, hierarchy code management at el. should go into
> > >> cgroup.c and it gives us clear view rather than implemented under memcg.
> > >>
> > >
> > > cgroup has hierarchy management already, in the form of children and
> > > sibling. Walking those structures is up to us, that is all we do
> > > currently :)
> > >
> > yes, but need cgroup_lock(). and you have to keep refcnt to pointer
> > just for rememebring it.
> > 
> > This patch doesn't change anything other than removing cgroup_lock() and
> > removing refcnt to remember start point.
> >
> 
> OK, I'll play with it 
> 
I hear Kosaki has another idea to 5/6. So please ignore 5/6 for a while.
It's complicated. I'll post updated ones.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
