Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC0C8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:06:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so2248404edm.18
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 05:06:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8-v6si7452526ejd.261.2018.12.20.05.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 05:06:08 -0800 (PST)
Date: Thu, 20 Dec 2018 14:06:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220130606.GG9104@dhcp22.suse.cz>
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
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 20-12-18 13:49:28, Oscar Salvador wrote:
> On Thu, Dec 20, 2018 at 10:12:28AM +0100, Michal Hocko wrote:
> > > <--
> > > skip_pages = (1 << compound_order(head)) - (page - head);
> > > iter = skip_pages - 1;
> > > --
> > > 
> > > which looks more simple IMHO.
> > 
> > Agreed!
> 
> Andrew, can you please apply the next diff chunk on top of the patch:
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4812287e56a0..978576d93783 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8094,7 +8094,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  				goto unmovable;
>  
>  			skip_pages = (1 << compound_order(head)) - (page - head);
> -			iter = round_up(iter + 1, skip_pages) - 1;
> +			iter = skip_pages - 1;

You did want iter += skip_pages - 1 here right?

-- 
Michal Hocko
SUSE Labs
