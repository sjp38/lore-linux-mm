Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A264FC76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:32:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67C7222387
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:32:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OJbTYpES"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67C7222387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6D738E0023; Wed, 24 Jul 2019 22:32:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1E4F8E001C; Wed, 24 Jul 2019 22:32:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0CBD8E0023; Wed, 24 Jul 2019 22:32:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B8778E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:32:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z1so29829266pfb.7
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:32:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bWUlBD6aLwE7AKkOlRWnXJ9c6g+3TfJmXMVXnOyImKg=;
        b=aXyiH74ScqTmIhg143xRTXMnwe73oOVXzs4jKNlTDbhIEsufgopJ8ThvRsBbtNmIUo
         JV0gJ9v7yzbboWk/dlyQ7uWYDTui9gOVSZ5SWED1xYQFyLfKocG5QxLNaGO/MFIBc1nK
         kqO7MFMVQZS0wHuLuLe7jB3LKOCSQDNtHGoYzqd3qnLw7qpgCMxg0+iZyJXg2nHt4E/m
         C5jrX8nz2o5CIWKZenOOPm4s0TmdwkBFe/BYKI5fr4Iq7HqJZPBMpoj5cKySPDc+Z4eF
         +jeQy6hpqucext24y0IqrtaDi15nxBjkm/q4a9YmTcswlq+g9hTtFTbstONM4oSWixe1
         WJcw==
X-Gm-Message-State: APjAAAU/GHO/NEh82lX+MgnEMHVQFaDN0kdSmpq34jGYd7bxBg/3nGDW
	pcGkGFLsLTM/+iOP/VmdfcEHsdVJ9x7ofrae3GY3Nig1PjOOzT4Jhx1S0BYmEpEt/OyQm75439H
	hYoGAxOAyTxNrQky/raE2t7sx8woufyR5GCUmEAIKPSfY+LxRoSILxr2FbtZEZ4Dd7w==
X-Received: by 2002:a17:902:7043:: with SMTP id h3mr60807847plt.10.1564021972260;
        Wed, 24 Jul 2019 19:32:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6UEk/QOqWJE1Et9miQfqwgHTAM2BWfkKLYpr48iVmdzkHEq/ONxM+H5+LYpzBnQ1UJ/x7
X-Received: by 2002:a17:902:7043:: with SMTP id h3mr60807800plt.10.1564021971467;
        Wed, 24 Jul 2019 19:32:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564021971; cv=none;
        d=google.com; s=arc-20160816;
        b=B7Y01lcbeGdbXWzfYkaR26nEt4ESgmxn4x3NID4alGUxHsfBpcvaZfWrSjUB8f0RBR
         7JLGyi4Drf1x6B+tywggEzEk7PGu/DrRDZ08GpemXxO8bTxQCe7rDMSsdW2ckHWKCaCD
         B3n4lyIACfMEj7NnnHxlE+EUy8lihWTdRU8P4oPRbO0KDXQery4D+PrEzVH5GZaDkrKL
         YHZX1LE2yRcnvOQ5D8fU04IncZNSYsATlJ3KVplniH4UanjfhDZOJW9cr2qv+IttPtQq
         ODbeOHNjwrL+wnKKr4ron7NRLEJzanWe2sPl6NjXDWupTzmbZIVBS3vC67piTV/0oBQV
         5q5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bWUlBD6aLwE7AKkOlRWnXJ9c6g+3TfJmXMVXnOyImKg=;
        b=CfvRMJauIbOIbRbEsV6xbN6lVgS0FBpA+K2Jkb5dYxE2LQm/kS8QcNbkERbjJW5/0z
         2fcYBpcYNRbgzg3QYBtkxixL0+2blZV3a5CSXNgW0tuld1uS8jNAK3Uh/hndBC771ki4
         yzRWgYJnazkGGGAEY6dp6qzDlQLUFBOYB31jb0Np+CUFdSkr5TndbqMY3NPMWWcJJ6mx
         Qu3YiTu5JjeZxpdtmdMH1phcmG83xTOPPFYQI3VA3/IK7sMWE4rb/dNVezbVc8wUWZ2Y
         BsQB4FGkYcRRI8xr0edHuLpZQl6YGuKmFYAiACbt/VCUph009OoVKZ0voh255H6hmFGN
         PW/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OJbTYpES;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id br18si15714945pjb.52.2019.07.24.19.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 19:32:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OJbTYpES;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7D44321734;
	Thu, 25 Jul 2019 02:32:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564021971;
	bh=ibY4e/drCaKLwNL3K3X/eLcpITyljqY6j1fyxEzgnFA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=OJbTYpESLMzczubKldo96bh7CeNd2DIEtY440m44fauTpRt9BrxvVQh0yAwfOuROF
	 iZe7fMFTVCgEaKT67hOlvIOsI0AFUW7pilJcU+4prrYzwSOqmsJsfRRQ4Rkr2TvTpP
	 lGAVkY3ofEeOd5cQ8/85Yyi3lqltPIfZzVlQdtpg=
Date: Wed, 24 Jul 2019 19:32:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Jason
 Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Mauro
 Carvalho Chehab <mchehab+samsung@kernel.org>, Matthew Wilcox
 <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Peng Fan
 <peng.fan@nxp.com>, Ira Weiny <ira.weiny@intel.com>, Andrey Ryabinin
 <aryabinin@virtuozzo.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: replace list_move_tail() with
 add_page_to_lru_list_tail()
Message-Id: <20190724193249.00875235c4fa2495e0098451@linux-foundation.org>
In-Reply-To: <20190716212436.7137-1-yuzhao@google.com>
References: <20190716212436.7137-1-yuzhao@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jul 2019 15:24:36 -0600 Yu Zhao <yuzhao@google.com> wrote:

> This is a cleanup patch that replaces two historical uses of
> list_move_tail() with relatively recent add_page_to_lru_list_tail().
> 

Looks OK to me.

> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -515,7 +515,6 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  	del_page_from_lru_list(page, lruvec, lru + active);
>  	ClearPageActive(page);
>  	ClearPageReferenced(page);
> -	add_page_to_lru_list(page, lruvec, lru);
>  
>  	if (PageWriteback(page) || PageDirty(page)) {
>  		/*
> @@ -523,13 +522,14 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  		 * It can make readahead confusing.  But race window
>  		 * is _really_ small and  it's non-critical problem.
>  		 */
> +		add_page_to_lru_list(page, lruvec, lru);
>  		SetPageReclaim(page);
>  	} else {
>  		/*
>  		 * The page's writeback ends up during pagevec
>  		 * We moves tha page into tail of inactive.
>  		 */

That comment is really hard to follow.  Minchan, can you please explain
the first sentence?

The second sentence can simply be removed.

> -		list_move_tail(&page->lru, &lruvec->lists[lru]);
> +		add_page_to_lru_list_tail(page, lruvec, lru);
>  		__count_vm_event(PGROTATED);
>  	}

