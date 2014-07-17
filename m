Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 86DE46B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 19:01:51 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so3926594pdb.10
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 16:01:51 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id bp9si1903277pdb.478.2014.07.17.16.01.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 16:01:50 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so4219400pab.30
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 16:01:50 -0700 (PDT)
Date: Thu, 17 Jul 2014 16:00:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 3/3] mm: vmscan: clean up struct scan_control
In-Reply-To: <20140717135721.GC8011@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1407171556460.2544@eggly.anvils>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org> <1405344049-19868-4-git-send-email-hannes@cmpxchg.org> <alpine.LSU.2.11.1407141240200.17669@eggly.anvils> <20140717132604.GF29639@cmpxchg.org> <20140717135721.GC8011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 17 Jul 2014, Michal Hocko wrote:
> On Thu 17-07-14 09:26:04, Johannes Weiner wrote:
> > From bbe8c1645c77297a96ecd5d64d659ddcd6984d03 Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Mon, 14 Jul 2014 08:51:54 -0400
> > Subject: [patch] mm: vmscan: clean up struct scan_control
> > 
> > Reorder the members by input and output, then turn the individual
> > integers for may_writepage, may_unmap, may_swap, compaction_ready,
> > hibernation_mode into bit fields to save stack space:
> > 
> > +72/-296 -224
> > kswapd                                       104     176     +72
> > try_to_free_pages                             80      56     -24
> > try_to_free_mem_cgroup_pages                  80      56     -24
> > shrink_all_memory                             88      64     -24
> > reclaim_clean_pages_from_list                168     144     -24
> > mem_cgroup_shrink_node_zone                  104      80     -24
> > __zone_reclaim                               176     152     -24
> > balance_pgdat                                152       -    -152
> > 
> > Suggested-by: Mel Gorman <mgorman@suse.de>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Looks nice to me.
> Acked-by: Michal Hocko <mhocko@suse.cz>

Yes, looks nice to me too; and I agree that it was worthwhile to make
those initialization orders consistent, and drop the 0 initializations.

Acked-by: Hugh Dickins <hughd@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
