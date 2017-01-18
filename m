Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31E066B0261
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:32:45 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id yr2so2494209wjc.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:32:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b79si20011056wma.103.2017.01.18.05.32.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 05:32:44 -0800 (PST)
Date: Wed, 18 Jan 2017 14:32:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [ATTEND] many topics
Message-ID: <20170118133243.GB7021@dhcp22.suse.cz>
References: <20170118054945.GD18349@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118054945.GD18349@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue 17-01-17 21:49:45, Matthew Wilcox wrote:
[...]
> 8. Nailing down exactly what GFP_TEMPORARY means

It's a hint that the page allocator should group those pages together
for better fragmentation avoidance. Have a look at e12ba74d8ff3 ("Group
short-lived and reclaimable kernel allocations"). Basically it is
something like __GFP_MOVABLE for kernel allocations which cannot go to
the movable zones.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
