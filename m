Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 304466B004F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 08:07:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7VC7EW5003870
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 31 Aug 2009 21:07:15 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C63C45DE6F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:07:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C0D845DE60
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:07:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 63F601DB803A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:07:14 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 131381DB8043
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:07:11 +0900 (JST)
Message-ID: <b18a62cbada2801ab34d591ba65ef906.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090831111027.GI4770@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
    <20090828132706.e35caf80.kamezawa.hiroyu@jp.fujitsu.com>
    <20090831111027.GI4770@balbir.in.ibm.com>
Date: Mon, 31 Aug 2009 21:07:10 +0900 (JST)
Subject: Re: [RFC][PATCH 4/5] memcg: per-cpu charge stock
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
> 13:27:06]:
>
>>
>> For avoiding frequent access to res_counter at charge, add per-cpu
>> local charge. Comparing with modifing res_coutner (with percpu_counter),
>> this approach
>> Pros.
>> 	- we don't have to touch res_counter's cache line
>> 	- we don't have to chase res_counter's hierarchy
>> 	- we don't have to call res_counter function.
>> Cons.
>> 	- we need our own code.
>>
>> Considering trade-off, I think this is worth to do.
>
> I prefer the other part due to
>
> 1. Code reuse (any enhancements made will benefit us)
> 2. Custom batching that can be done easily
> 3. Remember hierarchy is explicitly enabled and we've documented that
> it is expensive

Hmm. the important point is we don't touch res_counter's cacheline in
fast path. And if we don't use memcg's percpu counter, more cacheline/TLB
will be necesary. (I think percpu counter is slow.)
plz rewrite memcg's percpu counter by youself if you want something generic.

I can't understand what you mention by (3).

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
