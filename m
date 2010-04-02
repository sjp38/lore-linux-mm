Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A82AE6B01F5
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 15:06:07 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [10.3.21.5])
	by smtp-out.google.com with ESMTP id o32J63Bf007492
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 12:06:03 -0700
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by hpaq5.eem.corp.google.com with ESMTP id o32J61xN026498
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 21:06:01 +0200
Received: by pwj7 with SMTP id 7so1985934pwj.24
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 12:06:00 -0700 (PDT)
Date: Fri, 2 Apr 2010 12:05:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm 1/4] oom: select_bad_process: check PF_KTHREAD instead
 of !mm to skip kthreads
In-Reply-To: <20100402183132.GB31723@redhat.com>
Message-ID: <alpine.DEB.2.00.1004021205380.1773@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com>
 <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <20100402183057.GA31723@redhat.com>
 <20100402183132.GB31723@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Apr 2010, Oleg Nesterov wrote:

> select_bad_process() thinks a kernel thread can't have ->mm != NULL,
> this is not true due to use_mm().
> 
> Change the code to check PF_KTHREAD.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
