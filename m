Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id EBF796B006E
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 10:35:09 -0500 (EST)
Received: by wevl61 with SMTP id l61so16763272wev.0
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 07:35:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex9si10656020wic.44.2015.03.05.07.35.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 07:35:08 -0800 (PST)
Date: Thu, 5 Mar 2015 16:35:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC V3] mm: change mm_advise_free to clear page dirty
Message-ID: <20150305153505.GD19347@dhcp22.suse.cz>
References: <20150303032537.GA25015@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150303032537.GA25015@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Shaohua Li' <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>

On Tue 03-03-15 12:25:51, Minchan Kim wrote:
[...]
> From 30c6d5b35a3dc7e451041183ce5efd6a6c42bf88 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 3 Mar 2015 10:06:59 +0900
> Subject: [RFC] mm: make every pte dirty on do_swap_page

Hi Minchan, could you resend this patch separately. I am afraid that
this one got so convoluted with originally unrelated issues that
people might miss it.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
