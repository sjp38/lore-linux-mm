Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 220CD6B00C4
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 10:29:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7SETA2w009554
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 23:29:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7593945DE70
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:29:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 52A6B45DE6E
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:29:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 31CD91DB8044
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:29:10 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C82431DB8040
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:29:09 +0900 (JST)
Message-ID: <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090828132643.GM4889@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828072007.GH4889@balbir.in.ibm.com>
    <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132643.GM4889@balbir.in.ibm.com>
Date: Fri, 28 Aug 2009 23:29:09 +0900 (JST)
Subject: Re: [RFC][PATCH 1/5] memcg: change for softlimit.
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28
> 16:35:23]:
>

>>
>> Current soft-limit RB-tree will be easily broken i.e. not-sorted
>> correctly
>> if used under use_hierarchy=1.
>>
>
> Not true, I think the sorted-ness is delayed and is seen when we pick
> a tree for reclaim. Think of it as being lazy :)
>
plz explain how enexpectedly unsorted RB-tree can work sanely.


>> My patch disallows set softlimit to Bob and Mike, just allows against
>> Gold
>> because there can be considered as the same class, hierarchy.
>>
>
> But Bob and Mike might need to set soft limits between themselves. if
> soft limit of gold is 1G and bob needs to be close to 750M and mike
> 250M, how do we do it without supporting what we have today?
>
Don't use hierarchy or don't use softlimit.
(I never think fine-grain  soft limit can be useful.)

Anyway, I have to modify unnecessary hacks for res_counter of softlimit.
plz allow modification. that's bad.
I postpone RB-tree breakage problem, plz explain it or fix it by yourself.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
