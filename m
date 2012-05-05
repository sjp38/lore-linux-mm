Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id D343D6B00E7
	for <linux-mm@kvack.org>; Fri,  4 May 2012 20:07:18 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5572457pbb.14
        for <linux-mm@kvack.org>; Fri, 04 May 2012 17:07:18 -0700 (PDT)
Date: Sat, 5 May 2012 09:07:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
Message-ID: <20120505000710.GA2088@barrios>
References: <201205041603.25237.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201205041603.25237.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

Your patch doesn't handle my previous some comment so I coded up
some patches based on your patch. I don't care Andrew merge my patch
because your patch doesn't have a problem in point of working but at least
I want to tell some minor problems. If you agree this series, I hope
you merge this series into your patch and resend Andrew to not bother him.
