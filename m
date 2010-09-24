Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DAEB36B004A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 05:18:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8O9IDsZ022112
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 24 Sep 2010 18:18:13 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E817A45DE6F
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:18:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C6D4945DE60
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:18:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B13231DB803F
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:18:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61FC81DB803A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:18:12 +0900 (JST)
Date: Fri, 24 Sep 2010 18:13:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/2] memcg: use ID instead of pointer in page_cgroup ,
 retry.
Message-Id: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


This is a reviced series of use ID.
Restart from RFC.

[1/2] implementation of special ID lookup
[2/2] use ID in mm/memcontrol.c

People may say use css_lookup() and don't add a special routine but
I can't believw css_lookup() can give us enough speed at every page LRU handling
if the number of cgroup is big. I think this patch itself is enough simple...
but I admit this will make mem_cgroup more complex. Hmm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
