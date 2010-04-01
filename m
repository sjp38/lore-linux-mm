Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 74EB66B01EF
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:05:02 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [10.3.21.5])
	by smtp-out.google.com with ESMTP id o31J4xKt023124
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:04:59 -0700
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by hpaq5.eem.corp.google.com with ESMTP id o31J4gvq005035
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 21:04:57 +0200
Received: by pwj10 with SMTP id 10so1223626pwj.40
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:04:56 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:04:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] proc: don't take ->siglock for /proc/pid/oom_adj
In-Reply-To: <20100401153756.GD14603@redhat.com>
Message-ID: <alpine.DEB.2.00.1004011204430.30661@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com> <20100330174337.GA21663@redhat.com>
 <alpine.DEB.2.00.1003301329420.5234@chino.kir.corp.google.com> <20100331185950.GB11635@redhat.com> <alpine.DEB.2.00.1003311408520.31252@chino.kir.corp.google.com> <20100331230032.GB4025@redhat.com> <alpine.DEB.2.00.1004010128050.6285@chino.kir.corp.google.com>
 <20100401153756.GD14603@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Oleg Nesterov wrote:

> But. Unless we kill signal->oom_adj, we have another reason for ->siglock,
> we can't update both oom_adj and oom_score_adj atomically, and if we race
> with another thread they can be inconsistent wrt each other. Yes, oom_adj
> is not actually used, except we report it back to user-space, but still.
> 
> So, I am going to send 2 patches. The first one factors out the code
> in base.c and kills signal->oom_adj, the next one removes ->siglock.
> 

Great, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
