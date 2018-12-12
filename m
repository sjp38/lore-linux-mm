Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71C768E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:34:06 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so8540832edd.11
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 06:34:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9-v6si125591ejk.117.2018.12.12.06.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 06:34:04 -0800 (PST)
Date: Wed, 12 Dec 2018 15:34:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/5] mm: lower the printk loglevel for __dump_page
 messages
Message-ID: <20181212143402.GB7378@dhcp22.suse.cz>
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-3-mhocko@kernel.org>
 <20181212142540.GA7378@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212142540.GA7378@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 12-12-18 15:25:40, Michal Hocko wrote:
> It seems one follow up fix got lost on my side. Andrew, could you fold
> this in please?
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index 68e9a9f2df16..4c916e1abedc 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -88,7 +88,7 @@ void __dump_page(struct page *page, const char *reason)
>  	pr_warn("flags: %#lx(%pGp)\n", page->flags, &page->flags);
>  
>  hex_only:
> -	print_hex_dump(KERN_ALERT, "raw: ", DUMP_PREFIX_NONE, 32,
> +	print_hex_dump(KERN_WARN, "raw: ", DUMP_PREFIX_NONE, 32,
>  			sizeof(unsigned long), page,
>  			sizeof(struct page), false);

s@KERN_WARN@KERN_WARNING@ of course. Sigh. Sorry
-- 
Michal Hocko
SUSE Labs
