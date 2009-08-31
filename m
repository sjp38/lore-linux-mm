Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 495B16B005D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 10:36:14 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7VEaETY005631
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 31 Aug 2009 23:36:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CE77A45DE4E
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 23:36:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A6C1645DE4F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 23:36:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E745E1800A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 23:36:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 38AFF1DB803C
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 23:36:13 +0900 (JST)
Message-ID: <641cca8561405679780a7afa4442e2a5.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090831122316.GM4770@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132438.b33828bc.kamezawa.hiroyu@jp.fujitsu.com>
    <20090831110204.GG4770@balbir.in.ibm.com>
    <119e8331d1210b1f56d0f6416863bfbc.squirrel@webmail-b.css.fujitsu.com>
    <20090831121008.GL4770@balbir.in.ibm.com>
    <48d928bed22f20fc495e9ca1758dc7ed.squirrel@webmail-b.css.fujitsu.com>
    <20090831122316.GM4770@balbir.in.ibm.com>
Date: Mon, 31 Aug 2009 23:36:12 +0900 (JST)
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
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-31
> 21:14:10]:
>
>> Balbir Singh wrote:
>> >> > Does this effect deleting of a group and delay it by a large
>> amount?
>> >> >
>> >> plz see what cgroup_release_and_xxxx  fixed. This is not for delay
>> >> but for race-condition, which makes rmdir sleep permanently.
>> >>
>> >
>> > I've seen those patches, where rmdir() can hang. My conern was time
>> > elapsed since we do css_get() and do a cgroup_release_and_wake_rmdir()
>> >
>> plz read unmap() and truncate() code.
>> The number of pages handled without cond_resched() is limited.
>>
>>
>
> I understand that part, I was referring to tasks stuck doing rmdir()
> while we do batched uncharge, will it be very visible to the end user?
truncate/invalidate etc...is done in chunk of pagevec size.
Now, it's 14. then, batched uncharge is done per 14 pages, IIUC.

> cond_resched() is bad in this case.. since it means we'll stay longer
> before we release the cgroup.

cond_resched() is caller's matter. Not related memcg because we dont't
call it.

Thanks,
-Kame

>
>
> --
> 	Balbir
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
