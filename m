Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 768A26B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 17:14:50 -0400 (EDT)
Received: by lajy8 with SMTP id y8so12862087laj.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 14:14:49 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id s12si7818538lbm.84.2015.03.30.14.14.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 14:14:48 -0700 (PDT)
Received: by lajy8 with SMTP id y8so12861550laj.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 14:14:47 -0700 (PDT)
Date: Tue, 31 Mar 2015 00:14:46 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-ID: <20150330211446.GE18876@moon>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-4-git-send-email-minchan@kernel.org>
 <20150330052250.GA3008@blaptop>
 <20150330085112.GB10982@moon>
 <20150330085915.GC3008@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330085915.GC3008@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Mar 30, 2015 at 05:59:15PM +0900, Minchan Kim wrote:
> Hi Cyrill,
> 
> On Mon, Mar 30, 2015 at 11:51:12AM +0300, Cyrill Gorcunov wrote:
> > On Mon, Mar 30, 2015 at 02:22:50PM +0900, Minchan Kim wrote:
> > > 2nd description trial.
> > ...
> > Hi Minchan, could you please point for which repo this patch,
> > linux-next?
> 
> It was based on v4.0-rc5-mmotm-2015-03-24-17-02.
> As well, I confirmed it was applied on local-next-20150327.
> 
> Thanks.

Hi Minchan! I managed to fetch mmotm and the change looks
reasonable to me. Still better to wait for review from Mel
or Hugh, maybe I miss something obvious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
