Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC6316B008C
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:48:31 -0500 (EST)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id oB8LmRfh010372
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 13:48:28 -0800
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by kpbe12.cbf.corp.google.com with ESMTP id oB8LlsqZ007721
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 13:48:26 -0800
Received: by pwj10 with SMTP id 10so525198pwj.2
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 13:48:24 -0800 (PST)
Date: Wed, 8 Dec 2010 13:48:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: continuous oom caused system deadlock
In-Reply-To: <1334413603.521181291831873850.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1012081344490.15658@chino.kir.corp.google.com>
References: <1334413603.521181291831873850.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2010, CAI Qian wrote:

> Bisect indicated that this is the first bad commit,
> 
> commit 696d3cd5fb318c070dc757fe109e04e398138172
> Author: David Rientjes <rientjes@google.com>
> Date:   Fri Jun 11 22:45:17 2010 +0200
> 
>     __out_of_memory() only has a single caller, so fold it into
>     out_of_memory() and add a comment about locking for its call to
>     oom_kill_process().
>     
>     Signed-off-by: David Rientjes <rientjes@google.com>
>     Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>     Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 

This commit dropped the releasing of tasklist_lock when the oom killer 
chooses not to act because it finds another task that has already been 
killed but has yet to exit.  That's fixed by b52723c5, so this bisect 
isn't the source of your problem.

You didn't report the specific mmotm kernel that this was happening on, so 
trying to diagnose or reproduce it is diffcult.  Could you try 2.6.37-rc5 
with your test case?  If it works fine, could you try 
mmotm-2010-12-02-16-34?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
