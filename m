Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 035316B028B
	for <linux-mm@kvack.org>; Tue,  4 May 2010 19:56:05 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o44NtxKS015828
	for <linux-mm@kvack.org>; Tue, 4 May 2010 16:56:00 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by kpbe19.cbf.corp.google.com with ESMTP id o44NtvQn030016
	for <linux-mm@kvack.org>; Tue, 4 May 2010 16:55:58 -0700
Received: by pvc30 with SMTP id 30so539737pvc.27
        for <linux-mm@kvack.org>; Tue, 04 May 2010 16:55:57 -0700 (PDT)
Date: Tue, 4 May 2010 16:55:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100421121758.af52f6e0.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1005041655360.13683@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com> <20100407205418.FB90.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Apr 2010, Andrew Morton wrote:

> 
> fyi, I still consider these patches to be in the "stuck" state.  So we
> need to get them unstuck.
> 
> 
> Hiroyuki (and anyone else): could you please summarise in the briefest
> way possible what your objections are to Daivd's oom-killer changes?
> 
> I'll start: we don't change the kernel ABI.  Ever.  And when we _do_
> change it we don't change it without warning.
> 

Have we resolved all of the outstanding discussion concerning the oom 
killer rewrite?  I'm not aware of any pending issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
