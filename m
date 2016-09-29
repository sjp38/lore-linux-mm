Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2FCC6B0269
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:23:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so67072945wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:23:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j189si14191655wmj.143.2016.09.29.02.23.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 02:23:20 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: consolidate warn_alloc_failed users
References: <20160923081555.14645-1-mhocko@kernel.org>
 <20160929084407.7004-1-mhocko@kernel.org>
 <20160929084407.7004-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <100a197a-f173-6793-4237-473e54ef2767@suse.cz>
Date: Thu, 29 Sep 2016 11:23:18 +0200
MIME-Version: 1.0
In-Reply-To: <20160929084407.7004-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/29/2016 10:44 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> warn_alloc_failed is currently used from the page and vmalloc
> allocators. This is a good reuse of the code except that vmalloc would
> appreciate a slightly different warning message. This is already handled
> by the fmt parameter except that
>
> "%s: page allocation failure: order:%u, mode:%#x(%pGg)"
>
> is printed anyway. This might be quite misleading because it might be
> a vmalloc failure which leads to the warning while the page allocator is
> not the culprit here. Fix this by always using the fmt string and only
> print the context that makes sense for the particular context (e.g.
> order makes only very little sense for the vmalloc context). Rename
> the function to not miss any user and also because a later patch will
> reuse it also for !failure cases.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
