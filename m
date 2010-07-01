Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B4E586B01B4
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 20:06:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o61075RE014289
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 1 Jul 2010 09:07:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 192AA45DE7D
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6DF645DE7A
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 964531DB803A
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D16C1DB803F
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 07/11] oom: move OOM_DISABLE check from oom_kill_task to out_of_memory()
In-Reply-To: <20100630142034.GF15644@barrios-desktop>
References: <20100630183059.AA5C.A69D9226@jp.fujitsu.com> <20100630142034.GF15644@barrios-desktop>
Message-Id: <20100701090228.DA1C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu,  1 Jul 2010 09:07:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 30, 2010 at 06:31:36PM +0900, KOSAKI Motohiro wrote:
> > Now, if oom_kill_allocating_task is enabled and current have
> > OOM_DISABLED, following printk in oom_kill_process is called twice.
> > 
> >     pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> >             message, task_pid_nr(p), p->comm, points);
> > 
> > So, OOM_DISABLE check should be more early.
> 
> If we check it in oom_unkillable_task, we don't need this patch. 

Yup. but please read the commnet of [3/11].



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
