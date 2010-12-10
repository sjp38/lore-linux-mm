Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4FC7D6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:36:56 -0500 (EST)
Date: Thu, 9 Dec 2010 20:36:50 -0500 (EST)
From: caiqian@redhat.com
Message-ID: <1466079604.687011291945010525.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1541018294.686981291944921430.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: continuous oom caused system deadlock
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


> > The version is 2010-11-23-16-12 which included b52723c5 you mentioned. 
> > 2.6.37-rc5 had the same problem.
> > 
> The problem with your bisect is that you're bisecting in between 696d3cd5 
> and b52723c5 and identifying a problem that has already been fixed.
Both 2010-11-23-16-12 and 2.6.37-rc5 have b52723c5 but still have the problem with OOM testing. If went back one commit before 696d3cd5, it had no problem. Might be b52723c5 did not fix the problem fully?

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
