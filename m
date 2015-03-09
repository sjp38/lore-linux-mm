Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF7F6B0032
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 20:57:42 -0400 (EDT)
Received: by pabli10 with SMTP id li10so68341842pab.13
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 17:57:42 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id di4si3745392pad.57.2015.03.08.17.57.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Mar 2015 17:57:41 -0700 (PDT)
Received: by pdev10 with SMTP id v10so30404673pde.13
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 17:57:41 -0700 (PDT)
Date: Mon, 9 Mar 2015 09:57:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC V3] mm: change mm_advise_free to clear page dirty
Message-ID: <20150309005734.GC15184@blaptop>
References: <20150303032537.GA25015@blaptop>
 <20150305153505.GD19347@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150305153505.GD19347@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Shaohua Li' <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>

Hello Michal,

On Thu, Mar 05, 2015 at 04:35:05PM +0100, Michal Hocko wrote:
> On Tue 03-03-15 12:25:51, Minchan Kim wrote:
> [...]
> > From 30c6d5b35a3dc7e451041183ce5efd6a6c42bf88 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Tue, 3 Mar 2015 10:06:59 +0900
> > Subject: [RFC] mm: make every pte dirty on do_swap_page
> 
> Hi Minchan, could you resend this patch separately. I am afraid that
> this one got so convoluted with originally unrelated issues that
> people might miss it.
> 
> Thanks!

No problem. Thanks for the review.
I will resend it this week but I'm afraid everybody will be in LSF/MM
so they will be busy with hardwork in there. :)


> -- 
> Michal Hocko
> SUSE Labs

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
