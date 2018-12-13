Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32F748E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 10:35:27 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so1339953ede.19
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 07:35:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2si1038819edy.36.2018.12.13.07.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 07:35:25 -0800 (PST)
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 856E5ADD7
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 15:35:25 +0000 (UTC)
Date: Thu, 13 Dec 2018 15:35:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/6] blkdev: Avoid migration stalls for blkdev pages
Message-ID: <20181213153523.GE28934@suse.de>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-6-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181211172143.7358-6-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.cz

On Tue, Dec 11, 2018 at 06:21:42PM +0100, Jan Kara wrote:
> Currently, block device pages don't provide a ->migratepage callback and
> thus fallback_migrate_page() is used for them. This handler cannot deal
> with dirty pages in async mode and also with the case a buffer head is in
> the LRU buffer head cache (as it has elevated b_count). Thus such page can
> block memory offlining.
> 
> Fix the problem by using buffer_migrate_page_norefs() for migrating
> block device pages. That function takes care of dropping bh LRU in case
> migration would fail due to elevated buffer refcount to avoid stalls and
> can also migrate dirty pages without writing them.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs
