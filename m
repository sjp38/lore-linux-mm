Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E75135F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 04:04:32 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1394Uhs022494
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Feb 2009 18:04:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A96845DE4F
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:04:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EEBB545DE50
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:04:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E2034E18001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:04:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D371E18002
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:04:29 +0900 (JST)
Date: Tue, 3 Feb 2009 18:03:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/6] memcg/cgroup, updates related to CSS ID
Message-Id: <20090203180320.9f29aa76.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This is CSS ID series of patches. Some are for cgroup, others are for memcg.

No big changes from previous version. (*) is a patch for cgroup.
I think almost all comments are satisfied.
Isn't it not so bad time to start to test something new ?

[1/6] CSS ID for cgroup (*)
[2/6] use CSS ID in memcg's hierarchy.
[3/6] hierarchical stat for memcg
[4/6] fix shrink memory retry or -EBUSY
[5/6] fix oom killer under memcg hierarchy.
[6/6] fix frequent -EBUSY (*)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
