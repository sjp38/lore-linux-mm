Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 415D36B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 20:42:30 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so58191867pac.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:42:30 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id q3si19883028pdr.138.2015.03.18.17.42.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 17:42:29 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so58640465pdb.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:42:29 -0700 (PDT)
Date: Thu, 19 Mar 2015 09:42:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm:do recheck for freeable page in reclaim path
Message-ID: <20150319004221.GB9153@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>

Do not send your patch to this thread. It's second time.
Your patch is totally irrelevant to this patchset.
Send your patch as another thread.

On Wed, Mar 11, 2015 at 05:47:28PM +0800, Wang, Yalin wrote:
> In reclaim path, if encounter a freeable page,
> the try_to_unmap may fail, because the page's pte is
> dirty, we can recheck this page as normal non-freeable page,
> this means we can swap out this page into swap partition.

Pz, Pz, Pz write down more detail in description.

You mean page_check_references in shrink_page_list decided
it as freeable page but try_to_unmap failed because someone
touched the page during the race window between page_check_references
and try_to_unmap in shrink_page_list?

If so, it's surely recent referenced page so it should be promoted
to active list.

If I missed something, please write it down more detail in description
and send a patch as new thread, not sending it to this patchset thread.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
