Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 133916B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:37:24 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o7JKbMEQ030442
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:37:23 -0700
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by kpbe11.cbf.corp.google.com with ESMTP id o7JKaw4K030672
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:37:21 -0700
Received: by pxi17 with SMTP id 17so1143211pxi.29
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:37:21 -0700 (PDT)
Date: Thu, 19 Aug 2010 13:37:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] oom: fix tasklist_lock leak
In-Reply-To: <20100819195346.5FCA.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008191336060.18994@chino.kir.corp.google.com>
References: <20100819194707.5FC4.A69D9226@jp.fujitsu.com> <20100819195346.5FCA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, KOSAKI Motohiro wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
