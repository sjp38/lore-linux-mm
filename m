Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A3DA48D0001
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 20:40:30 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id oAS1b1hJ013520
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:37:01 -0800
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by hpaq5.eem.corp.google.com with ESMTP id oAS1axXa003667
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:37:00 -0800
Received: by pzk26 with SMTP id 26so739797pzk.35
        for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:36:58 -0800 (PST)
Date: Sat, 27 Nov 2010 17:36:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2]mm/oom-kill: direct hardware access processes should
 get bonus
In-Reply-To: <20101123154843.7B8D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011271733460.3764@chino.kir.corp.google.com>
References: <20101115095446.BF00.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011150159330.2986@chino.kir.corp.google.com> <20101123154843.7B8D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010, KOSAKI Motohiro wrote:

> > > > I think in cases of heuristics like this where we obviously want to give 
> > > > some bonus to CAP_SYS_ADMIN that there is consistency with other bonuses 
> > > > given elsewhere in the kernel.
> > > 
> > > Keep comparision apple to apple. vm_enough_memory() account _virtual_ memory.
> > > oom-killer try to free _physical_ memory. It's unrelated.
> > > 
> > 
> > It's not unrelated, the LSM function gives an arbitrary 3% bonus to 
> > CAP_SYS_ADMIN.  
> 
> Unrelated. LSM _is_ security module. and It only account virtual memory.
> 

I needed a small bias for CAP_SYS_ADMIN tasks so I chose 3% since it's the 
same proportion used elsewhere in the kernel and works nicely since the 
badness score is now a proportion.  If you'd like to propose a different 
percentage or suggest removing the bias for root tasks altogether, feel 
free to propose a patch.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
