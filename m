Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9SA9gFr028042
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Oct 2008 19:09:42 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5AD92AC026
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 19:09:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A056812C047
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 19:09:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CF1E1DB803C
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 19:09:41 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 47A941DB8037
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 19:09:41 +0900 (JST)
Date: Tue, 28 Oct 2008 19:09:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4][mmotm] memcg clean up
Message-Id: <20081028190911.6857b0a6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

This set is easy clean up and fixes to current memory resource controller in mmotm.

Contents are
 [1/4] make cgroup menu as submenu
 [2/4] divide mem_cgroup's charge behavior to charge/commit/cancel
 [3/4] fix gfp_mask of callers of mem_cgroup_charge_xxx
 [4/4] make memcg's page migration handler simple.

pushed out from memcg updates posted at 23/Oct. These are easy part.
all comments are applied (and spell check is done...)

They are against today's mmotm and tested on x86-64.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
