Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CDFDC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:40:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A31FA2070D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:40:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="eBpflH+8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A31FA2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5198E6B0003; Wed, 22 May 2019 17:40:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C9FA6B0006; Wed, 22 May 2019 17:40:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B9B46B0007; Wed, 22 May 2019 17:40:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02D966B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 17:40:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w2so2125499plq.0
        for <linux-mm@kvack.org>; Wed, 22 May 2019 14:40:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RAqzLVJ4I3ngDDWarXGW9nTPfulgyXATaSgETwk23M4=;
        b=eVKnE4niPCuuSZxM7/77lMWGcJ9QO5TeIe6O58EyhN+kqt6ddVtMIWCKIGtaKcF7Pg
         l3iapGA3oLqCkjbVsUt0ezRX8olJlyo2APdxX+ygJ5RwvJHyRyfxR8I1CqyZ53Cwb+sY
         fFlbTYuqLAHUne/u0nH5BUpsglSc1+n1DPoRSNb9BSI6Rda+op/DSuHJvt5zCm3Q2OS7
         38PLdU3uNnOnr9LxwAX4pASoGFKuK0+KjMNn3qkGJB2MYBrTDF5Czjdbk9wTmGZGC58s
         u5C2Muaj5TyUnIuO3rSlQ8uuEm4DUqZIZABFVAztq3+8ce8G5L9HgGogdroeKpHirI0p
         yIVQ==
X-Gm-Message-State: APjAAAUafaFkbEK+H2g9xL0QQnNKjyDtvcphVX+iUOSPMyJF++XqBQnW
	t8vaSQl1toR+x0gW44khhoPFIfBeD+3Qjj8XB5CNkc0wzZzLHI4II2nSS1x35cSlSSEKXhpC94X
	XWNmTDYkkCjH9bTYgJ1v4kuL6QV00KJEWjsOoPE3FxwwEJsiUf4fKT2Mw8risjGiASA==
X-Received: by 2002:a17:902:e492:: with SMTP id cj18mr34822802plb.341.1558561216606;
        Wed, 22 May 2019 14:40:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiairC/argpXPdB6KLcyfnZu8EeyrgSL2COOGmneC4aM6MnjzlR3CgAIAYQM4P8nMzycIw
X-Received: by 2002:a17:902:e492:: with SMTP id cj18mr34822731plb.341.1558561215537;
        Wed, 22 May 2019 14:40:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558561215; cv=none;
        d=google.com; s=arc-20160816;
        b=RbHHC49EF+YKeN+VBCDhOU2IN0et+EFp4/avkoSimRQC9TZNXv9xTH1KZQIBkF93YC
         VrYbK9XIPcCZjpRpBfMZedOTOBC8FqyRobzwDSlO06WGAyawbb8ccfummnZv4hkmTrLS
         re5T7YYlhGNblps1F/Zww7pEgvFwhnZ/WxwQAUQAfXoR7I4+v5m3xs6kTVZPczoPNUVs
         dYt82/DOQgoeB0jDle+WNg+sxN/BEQ8S8unTHiNL7R+6GjkpakcBYZDIlcVOsC2rzqPC
         UdRlbnzUcSWrdosoGQcbJcXrJf8wHrBxGE92D7HiBfeFB1Ae1+G8GZTKMgtu8cDsQoUX
         411g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RAqzLVJ4I3ngDDWarXGW9nTPfulgyXATaSgETwk23M4=;
        b=EDy08BC3xCO3vQuaFQvdjowE7cwjN5IAH/bRAZ7qWA4ecdXWfUbQKYzkeZWoolDdFD
         QLifpDJvheDohvrFSR0Gmx1G8i1HtZ2RkTzEuZrN9KdXjMGvvJHid1LcTMlF6Q1pGZev
         NP9OUb6ykIYj0GQxwvinmA8jGcn3Lchh7Y5JFYYFyNVLBR36z01XNPqDrevNaWHaxbzZ
         LFu4T9nHulpRoxBGj0KV4G9zGIz/Yizcj2GW6TKRT1/4ixDuPS2X6EXMmAHbOy6iEybc
         DQWH1potAugruI0Y2HU9u5E0GYiEod4Bf++F4815xusJSjGKOLzF7KWarMH7QYl6dkAV
         88GQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eBpflH+8;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t5si26546522pgj.258.2019.05.22.14.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 14:40:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eBpflH+8;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AAA662070D;
	Wed, 22 May 2019 21:40:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558561214;
	bh=TVtOFWGNImLj2bpnxfJhu9AklQ8LntOfzaAX9GX6wkA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=eBpflH+8xoV1F4jvCHoiaJQt9lsyr9eRQ637lTpPqeLFbtFBKIxexihv+TcXrprO/
	 Dca1d+3KPZHGNqh+/lXYCJqUQNEuDNLyH5P6Z1HB/dZr8eJFnuBnFra0V4ijVlK8Am
	 o1efS53m6fio9wHXYo/II7RpQidFfXW+NhC7Mg5Q=
Date: Wed, 22 May 2019 14:40:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: mhocko@suse.com, linux-mm@kvack.org, shaoyafang@didiglobal.com
Subject: Re: [PATCH 2/2] mm/vmscan: shrink slab in node reclaim
Message-Id: <20190522144014.9ea621c56cd80461fcd26a61@linux-foundation.org>
In-Reply-To: <1557389269-31315-2-git-send-email-laoar.shao@gmail.com>
References: <1557389269-31315-1-git-send-email-laoar.shao@gmail.com>
	<1557389269-31315-2-git-send-email-laoar.shao@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu,  9 May 2019 16:07:49 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:

> In the node reclaim, may_shrinkslab is 0 by default,
> hence shrink_slab will never be performed in it.
> While shrik_slab should be performed if the relcaimable slab is over
> min slab limit.
> 
> This issue is very easy to produce, first you continuously cat a random
> non-exist file to produce more and more dentry, then you read big file
> to produce page cache. And finally you will find that the denty will
> never be shrunk.

It does sound like an oversight.

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -4141,6 +4141,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
>  		.may_swap = 1,
>  		.reclaim_idx = gfp_zone(gfp_mask),
> +		.may_shrinkslab = node_page_state(pgdat, NR_SLAB_RECLAIMABLE) >
> +				  pgdat->min_slab_pages,
>  	};
>  
>  	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> @@ -4158,15 +4160,13 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
>  
> -	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {

Would it be better to do

	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages ||
			sc.may_shrinkslab) {

>  		/*
>  		 * Free memory by calling shrink node with increasing
>  		 * priorities until we have enough memory freed.
>  		 */

The above will want re-indenting and re-right-justifying.

> -		do {
> -			shrink_node(pgdat, &sc);
> -		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
> -	}
> +	do {
> +		shrink_node(pgdat, &sc);
> +	} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);

Won't this cause pagecache reclaim and compaction which previously did
not occur?  If yes, what are the effects of this and are they
desirable?  If no, perhaps call shrink_slab() directly in this case. 
Or something like that.

It's unclear why min_unmapped_pages (min_unmapped_ratio) exists.  Is it
a batch-things-up efficiency thing?

