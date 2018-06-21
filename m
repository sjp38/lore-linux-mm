Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 592036B0006
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 22:38:42 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m15-v6so1367786ioj.13
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 19:38:42 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 7-v6si2454888ioe.57.2018.06.20.19.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 19:38:41 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5L2ZhdI123096
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:38:40 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2jmr2mq1w4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:38:40 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5L2cdlD001380
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:38:39 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5L2cdr9010046
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:38:39 GMT
Received: by mail-ot0-f175.google.com with SMTP id p95-v6so1855903ota.5
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 19:38:38 -0700 (PDT)
MIME-Version: 1.0
References: <20180601125321.30652-1-osalvador@techadventures.net> <20180601125321.30652-5-osalvador@techadventures.net>
In-Reply-To: <20180601125321.30652-5-osalvador@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 20 Jun 2018 22:38:02 -0400
Message-ID: <CAGM2reYDLK1dE3RO3AoYNGzHX9HcozAxKvW+jzrgCThvTzjMpw@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm/memory_hotplug: Drop unnecessary checks from register_mem_sect_under_node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Fri, Jun 1, 2018 at 8:54 AM <osalvador@techadventures.net> wrote:
>
> From: Oscar Salvador <osalvador@suse.de>
>
> Callers of register_mem_sect_under_node() are always passing a valid
> memory_block (not NULL), so we can safely drop the check for NULL.
>
> In the same way, register_mem_sect_under_node() is only called in case
> the node is online, so we can safely remove that check as well.
>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

> ---
>  drivers/base/node.c | 5 -----
>  1 file changed, 5 deletions(-)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 248c712e8de5..681be04351bc 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -415,12 +415,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
>         int ret;
>         unsigned long pfn, sect_start_pfn, sect_end_pfn;
>
> -       if (!mem_blk)
> -               return -EFAULT;
> -
>         mem_blk->nid = nid;
> -       if (!node_online(nid))
> -               return 0;
>
>         sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
>         sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
> --
> 2.13.6
>
