Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AC9866B00C5
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 10:40:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7SEevxB021852
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 23:40:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A5B8E45DE51
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:40:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F7AC45DE50
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:40:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6624FE08003
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:40:57 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 113DEE38001
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 23:40:57 +0900 (JST)
Message-ID: <712c0209222358d9c7d1e33f93e21c30.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: 
     <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828072007.GH4889@balbir.in.ibm.com>
    <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132643.GM4889@balbir.in.ibm.com>
    <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com>
Date: Fri, 28 Aug 2009 23:40:56 +0900 (JST)
Subject: Re: [RFC][PATCH 1/5] memcg: change for softlimit.
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Balbir Singh wrote:
>> But Bob and Mike might need to set soft limits between themselves. if
>> soft limit of gold is 1G and bob needs to be close to 750M and mike
>> 250M, how do we do it without supporting what we have today?
>>
> Don't use hierarchy or don't use softlimit.
> (I never think fine-grain  soft limit can be useful.)
>
> Anyway, I have to modify unnecessary hacks for res_counter of softlimit.
> plz allow modification. that's bad.
> I postpone RB-tree breakage problem, plz explain it or fix it by yourself.
>
I changed my mind....per-zone RB-tree is also broken ;)

Why I don't like broken system is a function which a user can't
know/calculate how-it-works is of no use in mission critical systems.

I'd like to think how-to-fix it with better algorithm. Maybe RB-tree
is not a choice.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
