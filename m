Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63C848E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:49:32 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s27so1424425pgm.4
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:49:32 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id h67si19690207pfb.146.2018.12.20.04.49.30
        for <linux-mm@kvack.org>;
        Thu, 20 Dec 2018 04:49:30 -0800 (PST)
Date: Thu, 20 Dec 2018 13:49:28 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220091228.GB14234@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 10:12:28AM +0100, Michal Hocko wrote:
> > <--
> > skip_pages = (1 << compound_order(head)) - (page - head);
> > iter = skip_pages - 1;
> > --
> > 
> > which looks more simple IMHO.
> 
> Agreed!

Andrew, can you please apply the next diff chunk on top of the patch:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4812287e56a0..978576d93783 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8094,7 +8094,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 				goto unmovable;
 
 			skip_pages = (1 << compound_order(head)) - (page - head);
-			iter = round_up(iter + 1, skip_pages) - 1;
+			iter = skip_pages - 1;
 			continue;
 		}

Thanks!
-- 
Oscar Salvador
SUSE L3
