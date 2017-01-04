Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB1A6B025E
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 02:51:04 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so114278513wjb.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 23:51:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u8si76739692wmd.98.2017.01.03.23.51.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 23:51:02 -0800 (PST)
Date: Wed, 4 Jan 2017 08:50:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20170104075058.GA25453@dhcp22.suse.cz>
References: <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz>
 <20161230014853.GA4184@bbox>
 <20161230092636.GA13301@dhcp22.suse.cz>
 <20161230160456.GA7267@bbox>
 <20161230163742.GK13301@dhcp22.suse.cz>
 <20170103050328.GA15700@bbox>
 <20170103082122.GA30111@dhcp22.suse.cz>
 <20170104050722.GA17166@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104050722.GA17166@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 04-01-17 14:07:22, Minchan Kim wrote:
> On Tue, Jan 03, 2017 at 09:21:22AM +0100, Michal Hocko wrote:
[...]
> > with other tracepoints but that can be helpful because you do not have
> > all the tracepoints enabled all the time. So unless you see this
> > particular thing as a road block I would rather keep it.
> 
> I didn't know how long this thread becomes lenghy. To me, it was no worth
> to discuss. I did best effot to explain my stand with valid points, I think
> and don't want to go infinite loop. If you don't agree still, separate
> the patch. One includes only necessary things with removing nr_scanned, which
> I am happy to ack it. Based upon it, add one more patch you want adding
> nr_scanned with your claim. I will reply that thread with my claim and
> let's keep an eye on it that whether maintainer will take it or not.

To be honest this is just not worth the effort and rather than
discussing further I will just drop the nr_scanned slthough I disagree
that your concerns regarding this _particular counter_ are really valid.

> If maintainer will take it, it's good indication which will represent
> we can add more extra tracepoint easily with "might be helpful with someone
> although it's redunant" so do not prevent others who want to do
> in the future.

no we do not work in a precedence system like that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
