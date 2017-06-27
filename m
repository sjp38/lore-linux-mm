Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 851C16B02FD
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:47:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s65so26323228pfi.14
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:47:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f11si1979997pgn.154.2017.06.27.06.47.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 06:47:57 -0700 (PDT)
Date: Tue, 27 Jun 2017 06:47:51 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/6] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170627134751.GA28043@infradead.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-4-mhocko@kernel.org>
 <20170627084950.GI28072@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170627084950.GI28072@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>

On Tue, Jun 27, 2017 at 10:49:50AM +0200, Michal Hocko wrote:
> Christoph, Darrick
> could you have a look at this patch please? Andrew has put it into mmotm
> but I definitely do not want it passes your attention.

I don't think what we have to gain from it.  Callsite for KM_MAYFAIL
should handler failures, but the current behavior seems to be doing fine
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
