Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3578E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 08:50:53 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x67so1963867pfk.16
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 05:50:53 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id b3si3296604pgh.496.2019.01.15.05.50.51
        for <linux-mm@kvack.org>;
        Tue, 15 Jan 2019 05:50:52 -0800 (PST)
Date: Tue, 15 Jan 2019 14:50:49 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH] mm, memory_hotplug: __offline_pages fix wrong locking
Message-ID: <20190115135042.qxu2yoy3zs2fs6cy@d104.suse.de>
References: <20190115120307.22768-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115120307.22768-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Oscar Salvador <OSalvador@suse.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Jan 15, 2019 at 01:03:07PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Jan has noticed that we do double unlock on some failure paths when
> offlining a page range. This is indeed the case when test_pages_in_a_zone
> respp. start_isolate_page_range fail. This was an omission when forward
> porting the debugging patch from an older kernel.
> 
> Fix the issue by dropping mem_hotplug_done from the failure condition
> and keeping the single unlock in the catch all failure path.
> 
> Reported-by: Jan Kara <jack@suse.cz>
> Fixes: 7960509329c2 ("mm, memory_hotplug: print reason for the offlining failure")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Uhmf, I overlooked that while reviewing the patch.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
-- 
Oscar Salvador
SUSE L3
