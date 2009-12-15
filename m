Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AFFD36B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 00:03:15 -0500 (EST)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id nBF53BIM000964
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 05:03:11 GMT
Received: from pxi29 (pxi29.prod.google.com [10.243.27.29])
	by spaceape8.eur.corp.google.com with ESMTP id nBF538DD025746
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:03:09 -0800
Received: by pxi29 with SMTP id 29so2669457pxi.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:03:08 -0800 (PST)
Date: Mon, 14 Dec 2009 21:03:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.2
In-Reply-To: <20091215134319.CDD3.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912142100240.436@chino.kir.corp.google.com>
References: <20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0912142025090.29243@chino.kir.corp.google.com> <20091215134319.CDD3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009, KOSAKI Motohiro wrote:

> To compare vsz is only meaningful when the same program are compared.
> But oom killer don't. To compare vsz between another program DONT detect
> any memory leak.
> 

You're losing the ability to detect that memory leak because you'd be 
using a baseline that userspace cannot possibly know at the time of oom.  
You cannot possibly insist that users understand the amount of resident 
memory for all applications when tuning the heuristic adjuster from 
userspace.

In other words, how do you plan on userspace being able to identify tasks 
that are memory leakers if you change the baseline to rss?  Unless you 
have an answer to this question, you're not admitting the problem that 
the oom killer is primarily designed to address.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
