Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C0A6A6B00DC
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 22:24:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n263OZIa000519
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Mar 2009 12:24:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 599CC45DE64
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 12:24:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 385EE45DE63
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 12:24:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E03AE38008
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 12:24:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A8D84E38002
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 12:24:34 +0900 (JST)
Date: Fri, 6 Mar 2009 12:23:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090306122314.5314c8f5.kamezawa.hiroyu@jp.fujitsu.com>
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
> kswapd invokes soft limit reclaim. With 100 cgroups and 5 nodes, we'll
> end up scanning cgroups 500 times. There is no ordering of selected
> victims, so the largest victim might still be running unaffected.
> 
I think of more reasonable one. I'll post today if it goes well.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
