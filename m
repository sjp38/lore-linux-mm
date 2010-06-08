Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DFDA26B01D8
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:01:54 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id o58J1nN4009633
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:01:49 -0700
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by hpaq11.eem.corp.google.com with ESMTP id o58J1lWL018308
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:01:48 -0700
Received: by pvg2 with SMTP id 2so7178455pvg.2
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 12:01:47 -0700 (PDT)
Date: Tue, 8 Jun 2010 12:01:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 07/10] oom: kill useless debug print
In-Reply-To: <20100608205909.768F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081201100.18848@chino.kir.corp.google.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com> <20100608205909.768F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> Now, all of oom developers usually are using sysctl_oom_dump_tasks.
> Redundunt useless debug print can be removed.
> 

This is already removed with my heuristic rewrite as you well know, why 
are you constantly trying to get in the way of that work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
