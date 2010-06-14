Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E3AA16B01BF
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 04:55:09 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o5E8t4kg010755
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 01:55:04 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by kpbe12.cbf.corp.google.com with ESMTP id o5E8t2sd007837
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 01:55:03 -0700
Received: by pxi5 with SMTP id 5so497699pxi.31
        for <linux-mm@kvack.org>; Mon, 14 Jun 2010 01:55:02 -0700 (PDT)
Date: Mon, 14 Jun 2010 01:54:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 02/18] oom: sacrifice child with highest badness
 score for parent
In-Reply-To: <20100613184150.617E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006140154370.17771@chino.kir.corp.google.com>
References: <20100606175117.8721.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006081140030.18848@chino.kir.corp.google.com> <20100613184150.617E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jun 2010, KOSAKI Motohiro wrote:

> > > It mean we shouldn't assume parent and child have the same mems_allowed,
> > > perhaps.
> > > 
> > 
> > I'd be happy to have that in oom_kill_process() if you pass the
> > enum oom_constraint and only do it for CONSTRAINT_CPUSET.  Please add a 
> > followup patch to my latest patch series.
> 
> Please clarify.
> Why do we need CONSTRAINT_CPUSET filter?
> 

Because we don't care about intersecting mems_allowed unless it's a cpuset 
constrained oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
