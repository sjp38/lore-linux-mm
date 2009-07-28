Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C5766B004D
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 06:04:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6SA49CN026465
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Jul 2009 19:04:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A167245DE7F
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 19:04:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 753B845DE70
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 19:04:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3890B1DB8043
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 19:04:09 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C0BBFE08008
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 19:04:08 +0900 (JST)
Message-ID: <2c1ca41fbc03aeab347be61920e222b1.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <877hxti405.fsf@basil.nowhere.org>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
    <20090728161813.f2fefd29.kamezawa.hiroyu@jp.fujitsu.com>
    <877hxti405.fsf@basil.nowhere.org>
Date: Tue, 28 Jul 2009 19:04:07 +0900 (JST)
Subject: Re: [BUGFIX] set_mempolicy(MPOL_INTERLEAV) N_HIGH_MEMORY aware
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
>
>> tested on x86-64/fake NUMA and ia64/NUMA.
>> (That ia64 is a host which orignal bug report used.)
>>
>> Maybe this is bigger patch than expected, but NODEMASK_ALLOC() will be a
>> way
>> to go, anyway. (even if CPUMASK_ALLOC is not used anyware yet..)
>> Kosaki tested this on ia64 NUMA. thanks.
>
> Note that low/high memory support in NUMA policy is only partial
> anyways, e.g. the VMA based policy only supports a single zone. That
> was by design choice and because NUMA has a lot of issues on 32bit due
> to the limited address space and is not widely used.
>
> So small fixes are ok but I wouldn't go to large effort to fix NUMA
> policy on 32bit.
>
ya, maybe you mention to something related to policy_zone.
It's checked only in bind code now. (from before 2.6.30..)
The bug was accessing NODE_DATA(nid), which is NULL.
(All possible node doesn't have pgdat)

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
