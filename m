Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BCBF56B01AF
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 16:12:33 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o53KCTTC014999
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 13:12:29 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by wpaz33.hot.corp.google.com with ESMTP id o53KCRQX008409
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 13:12:28 -0700
Received: by pzk1 with SMTP id 1so336562pzk.8
        for <linux-mm@kvack.org>; Thu, 03 Jun 2010 13:12:27 -0700 (PDT)
Date: Thu, 3 Jun 2010 13:12:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 08/12] oom: dump_tasks() use find_lock_task_mm() too
In-Reply-To: <20100603152652.GA8743@redhat.com>
Message-ID: <alpine.DEB.2.00.1006031312130.10856@chino.kir.corp.google.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152350.725F.A69D9226@jp.fujitsu.com> <20100603152652.GA8743@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, Oleg Nesterov wrote:

> (off-topic)
> 
> out_of_memory() calls dump_header()->dump_tasks() lockless, we
> need tasklist.
> 

Already fixed in my rewrite patchset, as most of these things are.  Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
