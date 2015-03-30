Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id ABE7E6B006E
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 04:51:16 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so118559007wib.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 01:51:16 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id bb6si17219782wib.113.2015.03.30.01.51.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 01:51:15 -0700 (PDT)
Received: by wibgn9 with SMTP id gn9so118557874wib.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 01:51:14 -0700 (PDT)
Date: Mon, 30 Mar 2015 11:51:12 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-ID: <20150330085112.GB10982@moon>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-4-git-send-email-minchan@kernel.org>
 <20150330052250.GA3008@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330052250.GA3008@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Mar 30, 2015 at 02:22:50PM +0900, Minchan Kim wrote:
> 2nd description trial.
...
Hi Minchan, could you please point for which repo this patch,
linux-next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
