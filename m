Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 59F696B004F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 08:14:11 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7VCECOD009484
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 31 Aug 2009 21:14:14 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 45BEB2AEA8F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:14:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 157E11EF084
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:14:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C096C1DB803F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:14:11 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 324B2E08009
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:14:11 +0900 (JST)
Message-ID: <48d928bed22f20fc495e9ca1758dc7ed.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090831121008.GL4770@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132438.b33828bc.kamezawa.hiroyu@jp.fujitsu.com>
    <20090831110204.GG4770@balbir.in.ibm.com>
    <119e8331d1210b1f56d0f6416863bfbc.squirrel@webmail-b.css.fujitsu.com>
    <20090831121008.GL4770@balbir.in.ibm.com>
Date: Mon, 31 Aug 2009 21:14:10 +0900 (JST)
Subject: Re: [RFC][PATCH 2/5] memcg: uncharge in batched manner
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
>> > Does this effect deleting of a group and delay it by a large amount?
>> >
>> plz see what cgroup_release_and_xxxx  fixed. This is not for delay
>> but for race-condition, which makes rmdir sleep permanently.
>>
>
> I've seen those patches, where rmdir() can hang. My conern was time
> elapsed since we do css_get() and do a cgroup_release_and_wake_rmdir()
>
plz read unmap() and truncate() code.
The number of pages handled without cond_resched() is limited.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
