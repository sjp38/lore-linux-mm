Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFB86B025F
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 03:12:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b79so9006879pfk.9
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 00:12:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h69si335091pfe.479.2017.10.20.00.12.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 00:12:56 -0700 (PDT)
Date: Fri, 20 Oct 2017 09:12:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, thp: make deferred_split_shrinker memcg-aware
Message-ID: <20171020071250.ftqn2d356yekkp5k@dhcp22.suse.cz>
References: <20171019200323.42491-1-nehaagarwal@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019200323.42491-1-nehaagarwal@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Neha Agarwal <nehaagarwal@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Shaohua Li <shli@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu 19-10-17 13:03:23, Neha Agarwal wrote:
> deferred_split_shrinker is NUMA aware. Making it memcg-aware if
> CONFIG_MEMCG is enabled to prevent shrinking memory of memcg(s) that are
> not under memory pressure. This change isolates memory pressure across
> memcgs from deferred_split_shrinker perspective, by not prematurely
> splitting huge pages for the memcg that is not under memory pressure.

Why do we need this? THP pages are usually not shared between memcgs. Or
do you have a real world example where this is not the case? Your patch
is adding quite a lot of (and to be really honest very ugly) code so
there better should be a _very_ good reason to justify it. I haven't
looked very closely to the code, at least all those ifdefs in the code
are too ugly to live.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
