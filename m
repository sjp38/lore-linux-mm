Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id A41686B0081
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:43:00 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so2050581eek.12
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:43:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si13345992eeo.25.2013.12.10.00.42.59
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 00:42:59 -0800 (PST)
Date: Tue, 10 Dec 2013 08:42:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/18] sched: Tracepoint task movement
Message-ID: <20131210084257.GD11295@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-18-git-send-email-mgorman@suse.de>
 <52A611FB.7000305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52A611FB.7000305@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Drew Jones <drjones@redhat.com>

On Mon, Dec 09, 2013 at 01:54:51PM -0500, Rik van Riel wrote:
> On 12/09/2013 02:09 AM, Mel Gorman wrote:
> > move_task() is called from move_one_task and move_tasks and is an
> > approximation of load balancer activity. We should be able to track
> > tasks that move between CPUs frequently. If the tracepoint included node
> > information then we could distinguish between in-node and between-node
> > traffic for load balancer decisions. The tracepoint allows us to track
> > local migrations, remote migrations and average task migrations.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Does this replicate the task_sched_migrate_task tracepoint in
> set_task_cpu() ?
> 

There is significant overlap but bits missing. We do not necessarily know
where the task was previously running and whether this is a local->remote
migration. We also cannot tell the difference between load balancer activity,
numa balancing and try_to_wake_up. Still, you're right, this patch is not
painting a full picture either. I'll drop it for now and look at improving
the existing task_sched_migrate_task tracepoint.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
