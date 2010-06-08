Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19EB66B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:05:09 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o58J56EM020585
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:05:06 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by hpaq1.eem.corp.google.com with ESMTP id o58J4x5s014598
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:05:04 -0700
Received: by pvc21 with SMTP id 21so470507pvc.34
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 12:05:04 -0700 (PDT)
Date: Tue, 8 Jun 2010 12:05:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 09/10] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100608210148.7695.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081201530.18848@chino.kir.corp.google.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com> <20100608210148.7695.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> From: David Rientjes <rientjes@google.com>
> 
> Tasks that do not share the same set of allowed nodes with the task that
> triggered the oom should not be considered as candidates for oom kill.
> 

You're not a maintainer, as I obviously have to point out to you often 
enough.  I've repeatedly asked you to work with me in reviewing my oom 
killer rewrite on linux-mm, yet you seldom offer any valuable feedback 
other than a simple "nack".  I don't consider any of your patchset here to 
be more applicable than my patchset, which has been developed over the 
course of several months, and your lack of participation in the process is 
really quite shocking to me.

In case nobody has told you before: Andrew maintains this code and these 
patches will be going through the -mm tree.  You are not a maintainer of 
it (or any other kernel code), so please act within your role of kernel 
hacker and review patches as people propose them by offering your 
constructive feedback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
