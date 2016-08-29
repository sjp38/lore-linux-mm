Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A31BF830FE
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 10:14:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so99043182lfg.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 07:14:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r7si32281986wjt.42.2016.08.29.07.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 07:14:28 -0700 (PDT)
Date: Mon, 29 Aug 2016 10:10:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: clarify COMPACTION Kconfig text
Message-ID: <20160829141045.GB2172@cmpxchg.org>
References: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Aug 23, 2016 at 10:09:17AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> The current wording of the COMPACTION Kconfig help text doesn't
> emphasise that disabling COMPACTION might cripple the page allocator
> which relies on the compaction quite heavily for high order requests and
> an unexpected OOM can happen with the lack of compaction. Make sure
> we are vocal about that.

I find it weird to even have this as a config option after we removed
lumpy reclaim. Why offer a configuration that may easily OOM on allocs
that we don't even consider "costly" to generate? There might be some
specialized setups that know they can live without the higher-order
allocations and rather have the savings in kernel size, but I'd argue
that for the vast majority of Linux setups compaction is an essential
part of our VM at this point. Seems like a candidate for EXPERT to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
