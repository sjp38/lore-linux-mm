Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6933760021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 21:03:30 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9313WIg007980
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 3 Oct 2009 10:03:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E1AC445DE4F
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 10:03:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C1D6C45DE4D
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 10:03:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA15E1DB8038
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 10:03:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 612F01DB803B
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 10:03:31 +0900 (JST)
Message-ID: <e5304c673c74c5e3bebaf6985a7ad8fa.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0910021839470.11884@gentwo.org>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
    <20091001165832.32248.32725.sendpatchset@localhost.localdomain>
    <alpine.DEB.1.00.0910021511030.18180@chino.kir.corp.google.com>
    <alpine.DEB.1.10.0910021839470.11884@gentwo.org>
Date: Sat, 3 Oct 2009 10:03:30 +0900 (JST)
Subject: Re: [patch] nodemask: make NODEMASK_ALLOC more general
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 2 Oct 2009, David Rientjes wrote:
>
>> NODEMASK_ALLOC(x, m) assumes x is a type of struct, which is
>> unnecessary.
>> It's perfectly reasonable to use this macro to allocate a nodemask_t,
>> which is anonymous, either dynamically or on the stack depending on
>> NODES_SHIFT.
>
> There is currently only one user of NODEMASK_ALLOC which is
> NODEMASK_SCRATCH.
>
yes.

> Can we generalize the functionality here? The macro is basically choosing
> between a slab allocation or a stack allocation depending on the
> configured system size.
>
> NUMA_COND__ALLOC(<type>, <min numa nodes for not using stack>,
> <variablename>)
>
> or so?
>
sounds reasonable.

It seems cpumask has ifdef CONFIG_CPUMASK_OFFSTACK

> Its likely that one way want to allocate other structures on the stack
> that may get too big if large systems need to be supported.
>

maybe using the same style as cpumask will be reasonable.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
