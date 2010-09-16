Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CEEF46B007D
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 01:52:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G5qwW7010079
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Sep 2010 14:52:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64ED945DE51
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 14:52:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F02845DE4F
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 14:52:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 149EC1DB803B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 14:52:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3126E18001
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 14:52:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 0/4] oom fixes for 2.6.36
Message-Id: <20100916144930.3BAE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Sep 2010 14:52:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, oss-security@lists.openwall.com, Solar Designer <solar@openwall.com>, Kees Cook <kees.cook@canonical.com>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>, Neil Horman <nhorman@tuxdriver.com>, linux-fsdevel@vger.kernel.org, pageexec@freemail.hu, Brad Spengler <spender@grsecurity.net>, Eugene Teo <eugene@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>


patch 1 and 2 fix crappy ABI breakage issue since 2.6.36-rc1.
patch 3 and 4 fix oom dodging issue by using execve

  1) oom: remove totalpage normalization from oom_badness()
  2) Revert "oom: deprecate oom_adj tunable"
  3) move cred_guard_mutex from task_struct to signal_struct
  4) oom: don't ignore rss in nascent mm




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
