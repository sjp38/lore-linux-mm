Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 615416B01D2
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 02:32:41 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o596Wbq2028101
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:32:37 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by kpbe18.cbf.corp.google.com with ESMTP id o596WZUn032079
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:32:36 -0700
Received: by pxi6 with SMTP id 6so2449971pxi.1
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 23:32:35 -0700 (PDT)
Date: Tue, 8 Jun 2010 23:32:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
In-Reply-To: <20100608202611.GA11284@redhat.com>
Message-ID: <alpine.DEB.2.00.1006082330160.30606@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com> <20100608202611.GA11284@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Oleg Nesterov wrote:

> > It's unnecessary to SIGKILL a task that is already PF_EXITING
> 
> This probably needs some explanation. PF_EXITING doesn't necessarily
> mean this process is exiting.
> 

I hope that my sentence didn't imply that it was, the point is that 
sending a SIGKILL to a PF_EXITING task isn't necessary to make it exit, 
it's already along the right path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
