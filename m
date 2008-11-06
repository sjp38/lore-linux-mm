Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA6ClQEX020717
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 21:47:26 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 44E1445DD87
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 21:47:26 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ECF445DD7C
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 21:47:25 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F6CB1DB803A
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 21:47:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F69E1DB8038
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 21:47:25 +0900 (JST)
Message-ID: <30704.10.75.179.61.1225975644.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0811061151130.26541@blonde.site>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com><49129493.9070103@linux.vnet.ibm.com>
    <20081106194153.220157ec.kamezawa.hiroyu@jp.fujitsu.com>
    <Pine.LNX.4.64.0811061151130.26541@blonde.site>
Date: Thu, 6 Nov 2008 21:47:24 +0900 (JST)
Subject: Re: [RFC][PATCH 7/6] memcg: add atribute (for change bahavior
     ofrmdir)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hugh Dickins said:
> On Thu, 6 Nov 2008, KAMEZAWA Hiroyuki wrote:
>> On Thu, 06 Nov 2008 12:24:11 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> > KAMEZAWA Hiroyuki wrote:
>> > >
>> > > 1. change force_empty to do move account rather than forget all
>> >
>> > I would like this to be selectable, please. We don't want to break
>> behaviour and
>> > not everyone would like to pay the cost of movement.
>>
>> How about a patch like this ? I'd like to move this as [2/7], if
>> possible.
>> It obviously needs painful rework. If I found it difficult, schedule
>> this as [7/7].
>>
>> BTW, cost of movement itself is not far from cost for force_empty.
>>
>> If you can't find why "forget" is bad, please consider one more day.
>
> My recollection from a year ago is that force_empty totally violated
> the rules established elsewhere, making a nonsense of it all: once a
> force_empty had been done, you couldn't really be sure of anything
> (perhaps it deserved a Taint flag).
>
yes. that was terrible. (but necessary to do so because we accounted
pages not on LRU or some other reason.)

> Without studying your proposals at all, I do believe you've a good
> chance of creating a sensible and consistent force_empty by moving
> account, and abandoning the old "forget all" approach completely.
>

yes. I'm very encouraged. thanks!
After patch [1/6]
  -> move all at force empty
After this
  -> move all or free (not forget) all.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
