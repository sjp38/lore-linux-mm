Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C8B866B008A
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 21:52:48 -0500 (EST)
Date: Wed, 8 Dec 2010 21:52:44 -0500 (EST)
From: caiqian@redhat.com
Message-ID: <328504308.562701291863164154.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1390696678.561621291861499485.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: continuous oom caused system deadlock
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


> > Bisect indicated that this is the first bad commit,
> > 
> > commit 696d3cd5fb318c070dc757fe109e04e398138172
> > Author: David Rientjes <rientjes@google.com>
> > Date:   Fri Jun 11 22:45:17 2010 +0200
> > 
> >     __out_of_memory() only has a single caller, so fold it into
> >     out_of_memory() and add a comment about locking for its call to
> >     oom_kill_process().
> >     
> >     Signed-off-by: David Rientjes <rientjes@google.com>
> >     Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >     Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> 
> This commit dropped the releasing of tasklist_lock when the oom killer
> chooses not to act because it finds another task that has already been
> killed but has yet to exit.  That's fixed by b52723c5, so this bisect
> isn't the source of your problem.
> 
> You didn't report the specific mmotm kernel that this was happening
> on, so trying to diagnose or reproduce it is diffcult.  Could you try
> 2.6.37-rc5 with your test case?  If it works fine, could you try 
> mmotm-2010-12-02-16-34?
The version is 2010-11-23-16-12 which included b52723c5 you mentioned. 2.6.37-rc5 had the same problem.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
