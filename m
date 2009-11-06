Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 14C266B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 03:55:22 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA68tKHF007789
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 17:55:20 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B59E45DE64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:55:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BDE745DE4F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:55:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D4381DF8001
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:55:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE1781DB803F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:55:19 +0900 (JST)
Date: Fri, 6 Nov 2009 17:52:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2] memcg make use of new percpu implementations
Message-Id: <20091106175242.6e13ee29.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

Recent updates on dynamic percpu allocation looks good and I tries to rewrite
memcg's poor implementation of percpu status counter.
(It's not NUMA-aware ...)
Thanks for great works.

For this time. I added Christoph to CC because I'm not fully sure my usage of
__this_cpu_xxx is correct...I'm glad if you check the usage when you have time.


Patch 1/2 is just clean up (prepare for patch 2/2)
Patch 2/2 is for percpu.

Tested on my 8cpu box and works well.
Pathcesa are against the latest mmotm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
