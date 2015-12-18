Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 826476B0005
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 12:25:57 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l126so73354740wml.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 09:25:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 137si5025247wmb.51.2015.12.18.09.25.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 09:25:56 -0800 (PST)
Subject: Re: [PATCH] mm/readahead.c, mm/vmscan.c: use lru_to_page instead of
 list_to_page
References: <35cab720b3e69d47f03c9ce36d680db336bb5683.1449585319.git.geliangtang@163.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56744194.80809@suse.cz>
Date: Fri, 18 Dec 2015 18:25:40 +0100
MIME-Version: 1.0
In-Reply-To: <35cab720b3e69d47f03c9ce36d680db336bb5683.1449585319.git.geliangtang@163.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/08/2015 03:40 PM, Geliang Tang wrote:
> list_to_page() in readahead.c is the same as lru_to_page() in vmscan.c.
> So I move lru_to_page to internal.h and drop list_to_page().

Looks like this would topically fit better to include/linux/mm_inline.h

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
