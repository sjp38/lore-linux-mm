Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EE9946B00DB
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:54:46 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n25Nsh2m007756
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Mar 2009 08:54:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FBEE45DE55
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 08:54:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 759F345DE51
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 08:54:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 58A24E38005
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 08:54:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 05BD91DB803B
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 08:54:43 +0900 (JST)
Date: Fri, 6 Mar 2009 08:53:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090306085323.a96cfb01.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090305152642.GA5482@balbir.in.ibm.com>
References: <20090302060519.GG11421@balbir.in.ibm.com>
	<20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302063649.GJ11421@balbir.in.ibm.com>
	<20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302124210.GK11421@balbir.in.ibm.com>
	<c31ccd23cb41f0f7594b3f56b20f0165.squirrel@webmail-b.css.fujitsu.com>
	<20090302174156.GM11421@balbir.in.ibm.com>
	<20090303085914.555089b1.kamezawa.hiroyu@jp.fujitsu.com>
	<20090303111244.GP11421@balbir.in.ibm.com>
	<20090305180410.a44035e0.kamezawa.hiroyu@jp.fujitsu.com>
	<20090305152642.GA5482@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Mar 2009 20:56:42 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-05 18:04:10]:
> 
> > On Tue, 3 Mar 2009 16:42:44 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > > I wrote
> > > > ==
> > > >  if (victim is not over soft-limit)
> > > > ==
> > > > ....Maybe this discussion style is bad and I should explain my approach in patch.
> > > > (I can't write code today, sorry.)
> > > > 
> > 
> > This is an example of my direction, " do it lazy" softlimit.
> > 
> > Maybe this is not perfect but this addresses almost all my concern.
> > I hope this will be an input for you.
> > I didn't divide patch into small pieces intentionally to show a big picture.
> > Thanks,
> > -Kame
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > An example patch. Don't trust me, this patch may have bugs.
> >
> 
> Well this is not do it lazy, all memcg's are scanned tree is built everytime
> kswapd invokes soft limit reclaim. 
tree is built ? no. there are not tree. And this is lazy. No impact until
kswapd runs.

> With 100 cgroups and 5 nodes, we'll
> end up scanning cgroups 500 times.
No. 100 cgroups. (kswapd works per node and all kswapd doesn't work at once.)

> There is no ordering of selected victims, 
I don't think this is necessary but if you want you can add it easily.

> so the largest victim might still be running unaffected.
> 
No problem from my point of view.

"Soft limit" is a hint from the user to show "if usage is larger than this,
recalaim from this cgroup is appropriate"

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
