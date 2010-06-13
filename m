Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CD5C66B01B4
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOtYj022673
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:55 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D57145DE51
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0854745DE4D
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E400E1DB804E
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9743C1DB8045
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] signals: introduce send_sigkill() helper
In-Reply-To: <20100610010023.GB4727@redhat.com>
References: <20100610005937.GA4727@redhat.com> <20100610010023.GB4727@redhat.com>
Message-Id: <20100613184334.6181.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Roland McGrath <roland@redhat.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> Cleanup, no functional changes.
> 
> There are a lot of buggy SIGKILL users in kernel. For example, almost
> every force_sig(SIGKILL) is wrong. force_sig() is not safe, it assumes
> that the task has the valid ->sighand, and in general it should be used
> only for synchronous signals. send_sig(SIGKILL, p, 1) or
> send_xxx(SEND_SIG_FORCED/SEND_SIG_PRIV) is not right too but this is not
> immediately obvious.
> 
> The only way to correctly send SIGKILL is send_sig_info(SEND_SIG_NOINFO)
> but we do not want to use this directly, because we can optimize this
> case later. For example, zap_pid_ns_processes() allocates sigqueue for
> each process in namespace, this is unneeded.
> 
> Introduce the trivial send_sigkill() helper on top of send_sig_info()
> and change zap_pid_ns_processes() as an example.
> 
> Note: we need more cleanups here, this is only the first change.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Great.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
