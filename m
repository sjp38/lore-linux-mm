Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1A17B6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:04:38 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB134Zms020155
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 12:04:35 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 581FC45DE55
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:04:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 337FB45DE53
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:04:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 07EC11DB8043
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:04:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AF0041DB803C
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 12:04:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] exec: copy-and-paste the fixes into compat_do_execve() paths
In-Reply-To: <20101130195602.GC11905@redhat.com>
References: <20101130195456.GA11905@redhat.com> <20101130195602.GC11905@redhat.com>
Message-Id: <20101201120530.ABB6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Dec 2010 12:04:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

> Note: this patch targets 2.6.37 and tries to be as simple as possible.
> That is why it adds more copy-and-paste horror into fs/compat.c and
> uglifies fs/exec.c, this will be cleanuped later.
> 
> compat_copy_strings() plays with bprm->vma/mm directly and thus has
> two problems: it lacks the RLIMIT_STACK check and argv/envp memory
> is not visible to oom killer.
> 
> Export acct_arg_size() and get_arg_page(), change compat_copy_strings()
> to use get_arg_page(), change compat_do_execve() to do acct_arg_size(0)
> as do_execve() does.
> 
> Add the fatal_signal_pending/cond_resched checks into compat_count() and
> compat_copy_strings(), this matches the code in fs/exec.c and certainly
> makes sense.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
