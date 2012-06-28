Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 564646B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 21:07:02 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2792018pbb.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:07:01 -0700 (PDT)
Date: Wed, 27 Jun 2012 18:06:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: excessive CPU utilization by isolate_freepages?
In-Reply-To: <4FEBAC42.3030800@kernel.org>
Message-ID: <alpine.DEB.2.00.1206271803280.10830@chino.kir.corp.google.com>
References: <4FEB8237.6030402@sandia.gov> <4FEB9E73.5040709@kernel.org> <4FEBA520.4030205@redhat.com> <alpine.DEB.2.00.1206271745170.9552@chino.kir.corp.google.com> <4FEBAC42.3030800@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>

On Thu, 28 Jun 2012, Minchan Kim wrote:

> >>> > > https://lkml.org/lkml/2012/6/21/30
> >> > 
> > Not sure if Jim is using memcg; if not, then this won't be helpful.
> > 
> 
> 
> It doesn't related to memcg.
> if compaction_alloc can't find suitable migration target, it returns NULL.
> Then, migrate_pages should be exit.
> 

If isolate_freepages() is going to fail, then this zone should have been 
skipped when checking for compaction_suitable().  In Jim's perf output, 
compaction_suitable() returns COMPACT_CONTINUE for a transparent hugepage.  
Why is zone_watermark_ok(zone, 0 low_wmark + 1024, 0, 0) succeeding if 
isolate_freepages() is going to fail?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
