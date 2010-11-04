Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAFA8D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 21:50:23 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id oA41oJHN002068
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 18:50:19 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq11.eem.corp.google.com with ESMTP id oA41oH71002190
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 18:50:18 -0700
Received: by pxi7 with SMTP id 7so97105pxi.22
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 18:50:17 -0700 (PDT)
Date: Wed, 3 Nov 2010 18:50:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re:[PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
In-Reply-To: <1288834737.2124.11.camel@myhost>
Message-ID: <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain> <1288827804.2725.0.camel@localhost.localdomain> <alpine.DEB.2.00.1011031646110.7830@chino.kir.corp.google.com> <AANLkTimjfmLzr_9+Sf4gk0xGkFjffQ1VcCnwmCXA88R8@mail.gmail.com>
 <1288834737.2124.11.camel@myhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Nov 2010, Figo.zhang wrote:

> > > CAP_SYS_RESOURCE also had better get 3% bonus for protection.
> > >
> > 
> > 
> > Would you like to elaborate as to why?
> > 
> > 
> 
> process with CAP_SYS_RESOURCE capibility which have system resource
> limits, like journaling resource on ext3/4 filesystem, RTC clock. so it
> also the same treatment as process with CAP_SYS_ADMIN.
> 

NACK, there's no justification that these tasks should be given a 3% 
memory bonus in the oom killer heuristic; in fact, since they can allocate 
without limits it is more important to target these tasks if they are 
using an egregious amount of memory.  CAP_SYS_RESOURCE threads have the 
ability to lower their own oom_score_adj values, thus, they should protect 
themselves if necessary like everything else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
