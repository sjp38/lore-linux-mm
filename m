Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6E61A6B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 17:14:55 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id 123so69210212wmz.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 14:14:55 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v188si28225638wmg.123.2016.01.18.14.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 14:14:54 -0800 (PST)
Date: Mon, 18 Jan 2016 17:14:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/1] mmzone: code cleanup for LRU stats.
Message-ID: <20160118221427.GA8657@cmpxchg.org>
References: <1453101492-37125-1-git-send-email-maninder1.s@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453101492-37125-1-git-send-email-maninder1.s@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maninder Singh <maninder1.s@samsung.com>
Cc: mhocko@kernel.org, vdavydov@virtuozzo.com, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, ajeet.y@samsung.com, pankaj.m@samsung.com, Vaneet Narang <v.narang@samsung.com>

On Mon, Jan 18, 2016 at 12:48:12PM +0530, Maninder Singh wrote:
> Replacing hardcoded values with enum lru_stats for LRU stats.
> 
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> Signed-off-by: Vaneet Narang <v.narang@samsung.com>

I don't think the code is hard to understand, it always says 'anon' or
'file' or similar for every context where it's important to understand
what the magic array index means.

And this patch makes the lines too long and unwieldy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
