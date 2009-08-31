Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6BD036B004F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 08:09:55 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7VC9u08004665
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 31 Aug 2009 21:09:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B839945DE4F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:09:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D01545DE4E
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:09:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8892C1DB803A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:09:56 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 451F51DB8038
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:09:56 +0900 (JST)
Message-ID: <360d07ecdf467c2e15231f420375ffee.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090831111146.GJ4770@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132809.ad7cfebc.kamezawa.hiroyu@jp.fujitsu.com>
    <20090831111146.GJ4770@balbir.in.ibm.com>
Date: Mon, 31 Aug 2009 21:09:55 +0900 (JST)
Subject: Re: [RFC][PATCH 5/5] memcg: drain per cpu stock
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Balbir Singh さんは書きました：
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28
> 13:28:09]:
>
>>
>> Add function for dropping per-cpu stock of charges.
>> This is called when
>> 	- cpu is unplugged.
>> 	- force_empty
>> 	- recalim seems to be not easy.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> The complexity of this patch and additional code make percpu_counter
> more attractive. Why not work on percpu_counter if that is not as good
> as we expect it to be and in turn help other exploiters as well.

- percpu counter is slow.
- percpu counter is "counter". we use res_counter not as counter but as
  accounting for "limit". This "borrow" charges is core of this patch.
- Adding "flush" ops for percpu counter will be much more mess.
- This implementation handles mem->res and mem->memsw at the same time.
  This reduces much overhead.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
