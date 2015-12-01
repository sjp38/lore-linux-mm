Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 058956B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 17:25:55 -0500 (EST)
Received: by padhx2 with SMTP id hx2so18549305pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 14:25:54 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id g14si16895546pfd.164.2015.12.01.14.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 14:25:54 -0800 (PST)
Received: by padhx2 with SMTP id hx2so18549150pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 14:25:54 -0800 (PST)
Date: Tue, 1 Dec 2015 14:25:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v1] mm: fix warning in comparing enumerator
In-Reply-To: <1448959032-754-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1512011425230.19510@chino.kir.corp.google.com>
References: <1448959032-754-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 1 Dec 2015, Naoya Horiguchi wrote:

> I saw the following warning when building mmotm-2015-11-25-17-08.
> 
> mm/page_alloc.c:4185:16: warning: comparison between 'enum zone_type' and 'enum <anonymous>' [-Wenum-compare]
>   for (i = 0; i < MAX_ZONELISTS; i++) {
>                 ^
> 
> enum zone_type is named like ZONE_* which is different from ZONELIST_*, so
> we are somehow doing incorrect comparison. Just fixes it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/page_alloc.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git mmotm-2015-11-25-17-08/mm/page_alloc.c mmotm-2015-11-25-17-08_patched/mm/page_alloc.c
> index e267faa..b801e6f 100644
> --- mmotm-2015-11-25-17-08/mm/page_alloc.c
> +++ mmotm-2015-11-25-17-08_patched/mm/page_alloc.c
> @@ -4174,8 +4174,7 @@ static void set_zonelist_order(void)
>  
>  static void build_zonelists(pg_data_t *pgdat)
>  {
> -	int j, node, load;
> -	enum zone_type i;
> +	int i, j, node, load;
>  	nodemask_t used_mask;
>  	int local_node, prev_node;
>  	struct zonelist *zonelist;

Obviously correct, but I would have thought we could just remove 'j' and 
used 'i' as our iterator through the entire function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
