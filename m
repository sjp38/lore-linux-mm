Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1B2836B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 11:06:25 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7SF6Oxx006583
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 29 Aug 2009 00:06:24 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 92E6445DE4F
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:06:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 73C2B45DE4E
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:06:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5859B1DB803F
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:06:24 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 13C491DB803A
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:06:24 +0900 (JST)
Message-ID: <b2d13270df033cc94ec4387e01c88c82.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090828144648.GO4889@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828072007.GH4889@balbir.in.ibm.com>
    <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132643.GM4889@balbir.in.ibm.com>
    <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com>
    <712c0209222358d9c7d1e33f93e21c30.squirrel@webmail-b.css.fujitsu.com>
    <20090828144648.GO4889@balbir.in.ibm.com>
Date: Sat, 29 Aug 2009 00:06:23 +0900 (JST)
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
> 23:40:56]:
>
>> KAMEZAWA Hiroyuki wrote:
>> > Balbir Singh wrote:
>> >> But Bob and Mike might need to set soft limits between themselves. if
>> >> soft limit of gold is 1G and bob needs to be close to 750M and mike
>> >> 250M, how do we do it without supporting what we have today?
>> >>
>> > Don't use hierarchy or don't use softlimit.
>> > (I never think fine-grain  soft limit can be useful.)
>> >
>> > Anyway, I have to modify unnecessary hacks for res_counter of
>> softlimit.
>> > plz allow modification. that's bad.
>> > I postpone RB-tree breakage problem, plz explain it or fix it by
>> yourself.
>> >
>> I changed my mind....per-zone RB-tree is also broken ;)
>>
>> Why I don't like broken system is a function which a user can't
>> know/calculate how-it-works is of no use in mission critical systems.
>>
>> I'd like to think how-to-fix it with better algorithm. Maybe RB-tree
>> is not a choice.
>>
>
> Soft limits are not meant for mission critical work :-) Soft limits is
> best effort and not a guaranteed resource allocation mechanism. I've
> mentioned in previous emails how we recover if we find the data is
> stale
>
yes. but can you explain how selection will be done to users ?
I can't.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
