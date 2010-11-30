Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 65EBF6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:05:31 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id oAUK5MIn020579
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:05:22 -0800
Received: from pva4 (pva4.prod.google.com [10.241.209.4])
	by wpaz29.hot.corp.google.com with ESMTP id oAUK5KvX027367
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:05:21 -0800
Received: by pva4 with SMTP id 4so1229268pva.5
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:05:20 -0800 (PST)
Date: Tue, 30 Nov 2010 12:05:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2]mm/oom-kill: direct hardware access processes should
 get bonus
In-Reply-To: <20101130220107.8328.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011301204010.12979@chino.kir.corp.google.com>
References: <20101123154843.7B8D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011271733460.3764@chino.kir.corp.google.com> <20101130220107.8328.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, KOSAKI Motohiro wrote:

> > I needed a small bias for CAP_SYS_ADMIN tasks so I chose 3% since it's the 
> > same proportion used elsewhere in the kernel and works nicely since the 
> > badness score is now a proportion.  
> 
> Why? Is this important than X?
> 

We have always preferred to break ties between applications by not 
preferring the root task over the user task in the oom killer.  If you'd 
like to remove this bonus for CAP_SYS_ADMIN, please propose a patch.  
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
