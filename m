Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 72F166B0038
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 07:58:30 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id l61so13501977wev.8
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 04:58:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p1si1490571wiy.93.2015.02.06.04.58.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Feb 2015 04:58:28 -0800 (PST)
Date: Fri, 6 Feb 2015 13:58:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20150206125825.GA4498@dhcp22.suse.cz>
References: <20141127144725.GB19157@dhcp22.suse.cz>
 <20141130235652.GA10333@bbox>
 <20141202100125.GD27014@dhcp22.suse.cz>
 <20141203000026.GA30217@bbox>
 <20141203101329.GB23236@dhcp22.suse.cz>
 <20141205070816.GB3358@bbox>
 <20141205083249.GA2321@dhcp22.suse.cz>
 <54D0F9BC.4060306@gmail.com>
 <20150203234722.GB3583@blaptop>
 <20150206003311.GA2347@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150206003311.GA2347@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu 05-02-15 16:33:11, Shaohua Li wrote:
[...]
> Did you think about move the MADV_FREE pages to the head of inactive LRU, so
> they can be reclaimed easily?

Yes this makes sense for pages living on the active LRU list. I would
preserve LRU ordering on the inactive list because there is no good
reason to make the operation more costly for inactive pages. On the
other hand having tons of to-be-freed pages on the active list clearly
sucks. Care to send a patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
