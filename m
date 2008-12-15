Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kvack.org (Postfix) with SMTP id 983546B0074
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 05:55:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBFAv18x019563
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Dec 2008 19:57:01 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D8522AEA81
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 19:57:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EB431EF081
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 19:57:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 01D051DB803A
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 19:57:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 95BACE18005
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 19:56:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 2.6.28-rc8 big regression in VM
In-Reply-To: <20081215095311.GB4422@ics.muni.cz>
References: <20081215110231.00DF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081215095311.GB4422@ics.muni.cz>
Message-Id: <20081215193305.06C4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Dec 2008 19:56:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, Dec 15, 2008 at 11:05:24AM +0900, KOSAKI Motohiro wrote:
> > I also don't reproduce your problem.
> > Could you get output of "cat /proc/meminfo", not only free command?
> 
> attached meminfo and vmstat after dropping caches.


MemTotal:        2016688 kB
MemFree:         1528748 kB
Buffers:             424 kB
Cached:           140060 kB
SwapCached:            0 kB
Active(anon):     329884 kB
Inactive(anon):        4 kB
Active(file):      23368 kB
Inactive(file):    47328 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       1542232 kB
SwapFree:        1542232 kB
Dirty:                64 kB
Writeback:             0 kB
AnonPages:        260100 kB
Mapped:            85036 kB


Usually, Cached - tmpfs ~= Active(file) + Inactive(file).
tmpfs file isn't droppable.

We should see Active(file) + Inactive(file) (= 70696kB) instead Cached.
In addition, drop_cache sysctl can't drop Mapped memory.

Then, this value isn't so wonder value, IMHO.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
