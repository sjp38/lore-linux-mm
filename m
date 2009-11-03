Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 093C06B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 15:34:20 -0500 (EST)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id nA3KYGeW025731
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 20:34:17 GMT
Received: from pxi8 (pxi8.prod.google.com [10.243.27.8])
	by zps38.corp.google.com with ESMTP id nA3KY2JP031266
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:34:14 -0800
Received: by pxi8 with SMTP id 8so4296357pxi.27
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 12:34:14 -0800 (PST)
Date: Tue, 3 Nov 2009 12:34:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][-mm][PATCH 0/6] oom-killer: total renewal
In-Reply-To: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911031229590.25890@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:

> Hi, as discussed in "Memory overcommit" threads, I started rewrite.
> 
> This is just for showing "I started" (not just chating or sleeping ;)
> 
> All implemtations are not fixed yet. So feel free to do any comments.
> This set is for minimum change set, I think. Some more rich functions
> can be implemented based on this.
> 
> All patches are against "mm-of-the-moment snapshot 2009-11-01-10-01"
> 
> Patches are organized as
> 
> (1) pass oom-killer more information, classification and fix mempolicy case.
> (2) counting swap usage
> (3) counting lowmem usage
> (4) fork bomb detector/killer
> (5) check expansion of total_vm
> (6) rewrite __badness().
> 
> passed small tests on x86-64 boxes.
> 

Thanks for looking into improving the oom killer!

I think it would be easier to merge the four different concepts you have 
here:

 - counting for swap usage (patch 2),

 - oom killer constraint reorganization (patches 1 and 3),

 - fork bomb detector (patch 4), and 

 - heuristic changes (patches 5 and 6)

into seperate patchsets and get them merged one at a time.  I think patch 
2 can easily be merged into -mm now, and patches 1 and 3 could be merged 
after cleaned up.  We'll probably need more discussion on the rest.

Patches 1 and 6 have whitespace damage, btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
