Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA4C36B0395
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:12:16 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id d4-v6so23518644wrn.15
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:12:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5-v6si969165edq.426.2018.05.09.01.12.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 01:12:15 -0700 (PDT)
Date: Wed, 9 May 2018 10:12:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memblock: print memblock_remove
Message-ID: <20180509081214.GE32366@dhcp22.suse.cz>
References: <20180508104223.8028-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180508104223.8028-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue 08-05-18 19:42:23, Minchan Kim wrote:
> memblock_remove report is useful to see why MemTotal of /proc/meminfo
> between two kernels makes difference.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/memblock.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 5228f594b13c..03d48d8835ba 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -697,6 +697,11 @@ static int __init_memblock memblock_remove_range(struct memblock_type *type,
>  
>  int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
>  {
> +	phys_addr_t end = base + size - 1;
> +
> +	memblock_dbg("memblock_remove: [%pa-%pa] %pS\n",
> +		     &base, &end, (void *)_RET_IP_);

Other callers of memblock_dbg use %pF. Is there any reason to be
different here?

Other that that looks ok to me.
-- 
Michal Hocko
SUSE Labs
