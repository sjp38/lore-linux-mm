Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BB8F36B00D5
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 10:26:59 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id n25FP7Fa022451
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 02:25:07 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n25FR4AH414020
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 02:27:06 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n25FQjwV011081
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 02:26:46 +1100
Date: Thu, 5 Mar 2009 20:56:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-ID: <20090305152642.GA5482@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090302060519.GG11421@balbir.in.ibm.com> <20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com> <20090302063649.GJ11421@balbir.in.ibm.com> <20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com> <20090302124210.GK11421@balbir.in.ibm.com> <c31ccd23cb41f0f7594b3f56b20f0165.squirrel@webmail-b.css.fujitsu.com> <20090302174156.GM11421@balbir.in.ibm.com> <20090303085914.555089b1.kamezawa.hiroyu@jp.fujitsu.com> <20090303111244.GP11421@balbir.in.ibm.com> <20090305180410.a44035e0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090305180410.a44035e0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-05 18:04:10]:

> On Tue, 3 Mar 2009 16:42:44 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > > I wrote
> > > ==
> > >  if (victim is not over soft-limit)
> > > ==
> > > ....Maybe this discussion style is bad and I should explain my approach in patch.
> > > (I can't write code today, sorry.)
> > > 
> 
> This is an example of my direction, " do it lazy" softlimit.
> 
> Maybe this is not perfect but this addresses almost all my concern.
> I hope this will be an input for you.
> I didn't divide patch into small pieces intentionally to show a big picture.
> Thanks,
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> An example patch. Don't trust me, this patch may have bugs.
>

Well this is not do it lazy, all memcg's are scanned tree is built everytime
kswapd invokes soft limit reclaim. With 100 cgroups and 5 nodes, we'll
end up scanning cgroups 500 times. There is no ordering of selected
victims, so the largest victim might still be running unaffected.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
