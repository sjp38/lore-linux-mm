Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 387566B01F0
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 04:09:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7P89YF9006871
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Aug 2010 17:09:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6717545DE51
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:09:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3974D45DE4D
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:09:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D43E1DB8050
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:09:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A2414E38001
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:09:33 +0900 (JST)
Date: Wed, 25 Aug 2010 17:04:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/5] memcg: towards I/O aware memcg v6.
Message-Id: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This is v6. Thank you all for kindly reviews.

Major changes from v5 is
 a) changed ID allocation logic. Maybe much clearer than v6.
 b) fixed typos and bugs.

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
