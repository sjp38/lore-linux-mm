Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 871636B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 04:59:24 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so161106932pad.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 01:59:24 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id pe2si9369394pdb.154.2015.03.30.01.59.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 01:59:23 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so161099809pac.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 01:59:23 -0700 (PDT)
Date: Mon, 30 Mar 2015 17:59:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-ID: <20150330085915.GC3008@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-4-git-send-email-minchan@kernel.org>
 <20150330052250.GA3008@blaptop>
 <20150330085112.GB10982@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330085112.GB10982@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@parallels.com>

Hi Cyrill,

On Mon, Mar 30, 2015 at 11:51:12AM +0300, Cyrill Gorcunov wrote:
> On Mon, Mar 30, 2015 at 02:22:50PM +0900, Minchan Kim wrote:
> > 2nd description trial.
> ...
> Hi Minchan, could you please point for which repo this patch,
> linux-next?

It was based on v4.0-rc5-mmotm-2015-03-24-17-02.
As well, I confirmed it was applied on local-next-20150327.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
