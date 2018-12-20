Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9EF88E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:09:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so2293028ede.14
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 05:09:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cc25-v6sor5742075ejb.20.2018.12.20.05.08.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 05:08:59 -0800 (PST)
Date: Thu, 20 Dec 2018 13:08:57 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220130857.yrzv5wzmiw7jbycb@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
 <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 01:49:28PM +0100, Oscar Salvador wrote:
>On Thu, Dec 20, 2018 at 10:12:28AM +0100, Michal Hocko wrote:
>> > <--
>> > skip_pages = (1 << compound_order(head)) - (page - head);
>> > iter = skip_pages - 1;
>> > --
>> > 
>> > which looks more simple IMHO.
>> 
>> Agreed!
>
>Andrew, can you please apply the next diff chunk on top of the patch:
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 4812287e56a0..978576d93783 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -8094,7 +8094,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> 				goto unmovable;
> 
> 			skip_pages = (1 << compound_order(head)) - (page - head);
>-			iter = round_up(iter + 1, skip_pages) - 1;
>+			iter = skip_pages - 1;

This complicated the calculation. 

The original code is correct.

iter = round_up(iter + 1, 1<<compound_order(head)) - 1;

> 			continue;
> 		}
>
>Thanks!
>-- 
>Oscar Salvador
>SUSE L3

-- 
Wei Yang
Help you, Help me
