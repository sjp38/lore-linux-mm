Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 511E56B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 05:42:29 -0400 (EDT)
Date: Thu, 11 Jul 2013 10:42:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: sched: numa: fix NUMA balancing when !SCHED_DEBUG
Message-ID: <20130711094225.GD1875@suse.de>
References: <51CDBA15.9000207@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51CDBA15.9000207@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 28, 2013 at 11:30:13AM -0500, Dave Kleikamp wrote:
> Commit 3105b86a defined numabalancing_enabled to control the enabling
> and disabling of automatic NUMA balancing, but it is never used.
> 
> I believe the intention was to use this in place of
> sched_feat_numa(NUMA).
> 
> Currently, if SCHED_DEBUG is not defined, sched_feat_numa(NUMA) will
> never be changed from the initial "false".
> 
> Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
