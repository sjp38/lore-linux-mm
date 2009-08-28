Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A08096B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 10:58:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7SEwiIA021365
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 23:58:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18A7F45DE50
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:58:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA60D45DE4F
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:58:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D039B1DB8040
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:58:43 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 894331DB8038
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:58:43 +0900 (JST)
Message-ID: <d50640bcbd1bb174caaca9714bbe03e5.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090828144539.GN4889@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828072007.GH4889@balbir.in.ibm.com>
    <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132643.GM4889@balbir.in.ibm.com>
    <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com>
    <20090828144539.GN4889@balbir.in.ibm.com>
Date: Fri, 28 Aug 2009 23:58:39 +0900 (JST)
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
> 23:29:09]:
>
>> Balbir Singh wrote:
>> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28
>> > 16:35:23]:
>> >
>>
>> >>
>> >> Current soft-limit RB-tree will be easily broken i.e. not-sorted
>> >> correctly
>> >> if used under use_hierarchy=1.
>> >>
>> >
>> > Not true, I think the sorted-ness is delayed and is seen when we pick
>> > a tree for reclaim. Think of it as being lazy :)
>> >
>> plz explain how enexpectedly unsorted RB-tree can work sanely.
>>
>>
>
> There are two checks built-in
>
> 1. In the reclaim path (we see how much to reclaim, compared to the
> soft limit)
> 2. In the dequeue path where we check if we really are over soft limit
>
that's not a point.

> I did lot of testing with the time based approach and found no broken
> cases, I;ve been testing it with the mmotm (event based approach and I
> am yet to see a broken case so far).
>
I'm sorry if I don't understand RB-tree.
I think RB-tree is a system which can sort inputs passed by caller
one by one and will be in broken state if value of nodes changed
while it's in tree. Wrong ?
While a subtree is
               7
              / \
             3   9
And, by some magic, the value can be changed without extract
               7
              / \
             13  9
The biggest is 13. But the biggest number which will be selecte will be "9".

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
