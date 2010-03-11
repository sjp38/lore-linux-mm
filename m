Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 695E76B00AE
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 02:56:52 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2B7unQA014674
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Mar 2010 16:56:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D08A45DE51
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 16:56:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C1C245DE50
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 16:56:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4032A1DB8037
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 16:56:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7F031DB803E
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 16:56:48 +0900 (JST)
Date: Thu, 11 Mar 2010 16:53:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/3] memcg: oom notifier at el. (v3)
Message-Id: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

Updated against mmotm-Mar9.

This patch set's feature is
 - add filter to memcg's oom waitq.
 - oom kill notifier for memcg.
 - oom kill disable for memcg.

Major changes since previous one are
 - add filter to wakeup queue.
 - use its own function and logic rather than reusing thresholds.
 - some minor fixes.

If oom-killer disabled, all tasks under memcg will sleep in memcg_oom_waitq.
What users can do when memcg-oom-killer is disabled is:
 - enlarge limit.
 - kill some task. ---(*)
 - move some task to other cgroup. (with account migration)
   (This patchset doesn't handle a case when account migraion isn't set.)

The benefit of (*) is that the user can save information of all tasks before
killing and he can take coredump (by gcore.) of troublesome process.

I'm now wondering when I remove RFC...but I think this will not have
much HUNK with dirty_ratio sets.

If some codes are unclear, feel free to request me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
