Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F06BE6B01B6
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:14:23 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o5LKEJLB029450
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:14:19 -0700
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by hpaq6.eem.corp.google.com with ESMTP id o5LKEH1j027935
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:14:18 -0700
Received: by pwj7 with SMTP id 7so3613770pwj.18
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:14:17 -0700 (PDT)
Date: Mon, 21 Jun 2010 13:14:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/9] oom: oom_kill_process() doesn't select kthread
 child
In-Reply-To: <20100617104517.FB7D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006211313080.8367@chino.kir.corp.google.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com> <20100617104517.FB7D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:

> 
> Now, select_bad_process() have PF_KTHREAD check, but oom_kill_process
> doesn't. It mean oom_kill_process() may choose wrong task, especially,
> when the child are using use_mm().
> 

This type of check should be moved to badness(), it will prevent these 
types of tasks from being selected both in select_bad_process() and 
oom_kill_process() if the score it returns is 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
