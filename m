Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7848B6B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:06:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so31127869wrc.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:06:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v124si2629881wma.151.2017.06.27.07.06.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 07:06:57 -0700 (PDT)
Date: Tue, 27 Jun 2017 16:06:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/6] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170627140654.GO28072@dhcp22.suse.cz>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-4-mhocko@kernel.org>
 <20170627084950.GI28072@dhcp22.suse.cz>
 <20170627134751.GA28043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170627134751.GA28043@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>

On Tue 27-06-17 06:47:51, Christoph Hellwig wrote:
> On Tue, Jun 27, 2017 at 10:49:50AM +0200, Michal Hocko wrote:
> > Christoph, Darrick
> > could you have a look at this patch please? Andrew has put it into mmotm
> > but I definitely do not want it passes your attention.
> 
> I don't think what we have to gain from it.  Callsite for KM_MAYFAIL
> should handler failures, but the current behavior seems to be doing fine
> too.

Last time I've asked I didnd't get any reply so let me ask again. Some
of those allocations seem to be small (e.g. by a random look
xlog_cil_init allocates struct xfs_cil which is 576B and struct
xfs_cil_ctx 176B). Those do not fail currently under most conditions and
it will retry allocation with the OOM killer if there is no progress. As
you know that failing those is acceptable, wouldn't it be better to
simply fail them and do not disrupt the system with the oom killer?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
