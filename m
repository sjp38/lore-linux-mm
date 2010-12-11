Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C3BB76B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 19:30:43 -0500 (EST)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id oBB0Ueog003715
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:30:40 -0800
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by hpaq6.eem.corp.google.com with ESMTP id oBB0UYdo026862
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:30:39 -0800
Received: by pxi17 with SMTP id 17so1026541pxi.34
        for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:30:34 -0800 (PST)
Date: Fri, 10 Dec 2010 16:30:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: continuous oom caused system deadlock
In-Reply-To: <1466079604.687011291945010525.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1012101628010.1501@chino.kir.corp.google.com>
References: <1466079604.687011291945010525.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: caiqian@redhat.com
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 2010, caiqian@redhat.com wrote:

> > > The version is 2010-11-23-16-12 which included b52723c5 you mentioned. 
> > > 2.6.37-rc5 had the same problem.
> > > 
> > The problem with your bisect is that you're bisecting in between 696d3cd5 
> > and b52723c5 and identifying a problem that has already been fixed.
> Both 2010-11-23-16-12 and 2.6.37-rc5 have b52723c5 but still have the 
> problem with OOM testing. If went back one commit before 696d3cd5, it 
> had no problem. Might be b52723c5 did not fix the problem fully?
> 

When a bisect identifies a commit in between a known-broken patch and fix 
for that broken patch, you need to revert your tree back to the fix 
(b52723c5) and retest.  If the problem persists, then 696d3cd5 is the bad 
commit.  Otherwise, you need to bisect between the fix (by labeling it 
with "git bisect good") and HEAD.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
