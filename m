Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 253946B005C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 05:30:12 -0500 (EST)
Message-ID: <4F057BF2.5040206@freescale.com>
Date: Thu, 5 Jan 2012 18:31:14 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/compaction : fix the wrong return value for isolate_migratepages()
References: <1325322585-16216-1-git-send-email-b32955@freescale.com> <20120105101222.GD28031@suse.de>
In-Reply-To: <20120105101222.GD28031@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, shijie8@gmail.com

hi,
> Why?
>
> Returning ISOLATE_SUCCESS means that we fall through. This means busy
> work in migrate_pages(), updating list accounting and the list. It's
> wasteful but is it functionally incorrect? What problem did you observe?
there may are many times the cc->migratepages is zero, but the return 
value is ISOLATE_SUCCESS.


> If this is simply a performance issue then minimally COMPACTBLOCKS
yes, My concern is the performance.

the comment of ISOLATE_NONE makes me confused.  :(

If you think we should update the COMPACTBLOCK in this case, my patch is 
wrong.


> still needs to be updated, we still want to see the tracepoint etc. To
ok.
> preserve that, I would suggest as an alternative to leave it returning
> ISOLATE_SUCCESS but move
>
>
>                 err = migrate_pages(&cc->migratepages, compaction_alloc,
>                                  (unsigned long)cc, false,
>                                  cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
>                  update_nr_listpages(cc);
>
> inside a if (nr_migrate) check to avoid some overhead.
>
thanks.
Huang Shijie


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
