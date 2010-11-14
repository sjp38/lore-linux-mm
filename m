Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7BB258D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:39:34 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id oAELdWwN027255
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 13:39:32 -0800
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by wpaz21.hot.corp.google.com with ESMTP id oAELdVas001900
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 13:39:31 -0800
Received: by pzk26 with SMTP id 26so728569pzk.8
        for <linux-mm@kvack.org>; Sun, 14 Nov 2010 13:39:30 -0800 (PST)
Date: Sun, 14 Nov 2010 13:39:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101114135323.E00D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011141333330.22262@chino.kir.corp.google.com>
References: <20101109105801.BC30.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011091523370.26837@chino.kir.corp.google.com> <20101114135323.E00D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:

> No irrelevant. Your patch break their environment even though
> they don't use oom_adj explicitly. because their application are using it.
> 

The _only_ difference too oom_adj since the rewrite is that it is now 
mapped on a linear scale rather than an exponential scale.  That's because 
the heuristic itself has a defined range [0, 1000] that characterizes the 
memory usage of the application it is ranking.  To show any breakge, you 
would have to show how oom_adj values being used by applications are based 
on a calculated value that prioritizes those tasks amongst each other.  
With the exponential scale, that's nearly impossible because of the number 
of arbitrary heuristics that were used before oom_adj were considered 
(runtime, nice level, CAP_SYS_RAWIO, etc).

So don't talk about userspace breakage when you can't even describe it or 
present a single usecase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
