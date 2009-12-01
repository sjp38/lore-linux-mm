Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6C8C2600309
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 00:14:09 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB15E61Z015449
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Dec 2009 14:14:07 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7765F45DE4E
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 14:14:06 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 58FE245DE4C
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 14:14:06 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 43DE51DB803E
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 14:14:06 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 028811DB803A
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 14:14:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: memcg: slab control
In-Reply-To: <604427e00911262315n5d520cf4p447f68e7053adc11@mail.gmail.com>
References: <4B0E7530.8050304@parallels.com> <604427e00911262315n5d520cf4p447f68e7053adc11@mail.gmail.com>
Message-Id: <20091201140726.5C28.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Dec 2009 14:14:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Pavel Emelyanov <xemul@parallels.com>, Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> We can either not count those allocations, or do some special
> treatment to remember who owns those allocations.
> In our networking intensive workload, it causes us lots of trouble of
> miscounting the networking slabs for incoming
> packets. So we make changes in the networking stack which records the
> owner of the socket and then charge the
> slab later using that recorded information.

I agree, currentlly network intensive workload is problematic. but I don't think
network memory management improvement need to change generic slab management.

Why can't we improve current tcp/udp memory accounting? it is good user interface than
"amount of slab memory".


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
