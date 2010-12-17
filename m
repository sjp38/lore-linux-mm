Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9CBB16B0093
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:16:37 -0500 (EST)
Date: Thu, 16 Dec 2010 23:16:30 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1442556949.1332491292559390301.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <alpine.DEB.2.00.1012101628010.1501@chino.kir.corp.google.com>
Subject: Re: continuous oom caused system deadlock
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi David,

> When a bisect identifies a commit in between a known-broken patch and fix 
> for that broken patch, you need to revert your tree back to the fix 
> (b52723c5) and retest.  If the problem persists, then 696d3cd5 is the bad 
> commit.  Otherwise, you need to bisect between the fix (by labeling it
> with "git bisect good") and HEAD.
It turned out that this bug is not always reproducible after your fix. Sorry for the false alarm.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
