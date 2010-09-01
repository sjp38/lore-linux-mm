Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DF5836B0047
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 02:45:08 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o816j5ef007758
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Sep 2010 15:45:06 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D31B545DE50
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:45:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B5C3E45DE4F
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:45:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 98D881DB8012
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:45:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D59411DB8018
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:45:01 +0900 (JST)
Date: Wed, 1 Sep 2010 15:39:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/5] memcg: towards I/O aware memcg v7.
Message-Id: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, gthelen@google.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, menage@google.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Major changes from v6 is
 a) added documentation about CSS ID.
 b) fixed typos and bugs.
 c) refleshed some comments

based on mmotm-2010-08-27

Patch brief view:
 1. changes css ID allocation in kernel/cgroup.c
 2. use ID-array in memcg.
 3. record ID to page_cgroup rather than pointer.
 4. make update_file_mapped to be RCU aware routine instead of spinlock.
 5. make update_file_mapped as general-purpose function.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
