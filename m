Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D25F46B01FE
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:57:21 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7JNvJon030083
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 20 Aug 2010 08:57:19 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 53F8945DE60
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:57:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 192BA45DE4D
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:57:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EEDF31DB8037
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:57:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BFFD1DB803A
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:57:15 +0900 (JST)
Date: Fri, 20 Aug 2010 08:52:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] oom: fix tasklist_lock leak
Message-Id: <20100820085224.ca96c878.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100819195346.5FCA.A69D9226@jp.fujitsu.com>
References: <20100819194707.5FC4.A69D9226@jp.fujitsu.com>
	<20100819195346.5FCA.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010 19:54:06 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> commit 0aad4b3124 (oom: fold __out_of_memory into out_of_memory)
> introduced tasklist_lock leak. Then it caused following obvious
> danger warings and panic.
> 
>     ================================================
>     [ BUG: lock held when returning to user space! ]
>     ------------------------------------------------
>     rsyslogd/1422 is leaving the kernel with locks still held!
>     1 lock held by rsyslogd/1422:
>      #0:  (tasklist_lock){.+.+.+}, at: [<ffffffff810faf64>] out_of_memory+0x164/0x3f0
>     BUG: scheduling while atomic: rsyslogd/1422/0x00000002
>     INFO: lockdep is turned off.
> 
> This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
