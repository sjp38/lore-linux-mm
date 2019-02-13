Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69AB0C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:41:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27C6D20835
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:41:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27C6D20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD8A48E0002; Wed, 13 Feb 2019 09:41:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A88C28E0001; Wed, 13 Feb 2019 09:41:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99E9E8E0002; Wed, 13 Feb 2019 09:41:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 588AB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:41:06 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a23so2053441pfo.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:41:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nvlwPyQYARni0b3cZG9bzQyjlrPfoDOryJPlL9uYpF0=;
        b=Pfz5nws3TuSNK+LJ3+IrELzPr44j1L5ZW+WExSv0H88kPpcIOzoo+N6gZo7ECdXEPr
         NfUaqIEoUpDmN6D/iIPlAYcHU28NjRJRUW3dwRQb+w7XE+sK0fHMiFWrS8rH4M2Hy0np
         HHv3I2oDIzI0BUHCp6ZjuygufnQip2q1g7lYNHT5KtO8H/c3/GaRXU3tq+SJXl1HDMW8
         CyTLfPxvpWcfG4kSGMYYojpPqQxvGXxukBxcCIE/XWuuBZmyS8P/kAIEPUdFaasWDgno
         3odKMJkl1bovL2AlbqAcwhAnyVExfyCsepysGHSaUEQYiRUIFGZjqyYM0t1FFR8P0WmY
         la+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAubT2R3CXbB9x+3ahRSo8jXTrgBZR8Gusr3rFyIJjSlNYfeuHxNh
	xSqcXhBD221WA8Fy8r/zRjxaseZ4XMuuT+l3DDDsa2BL7Ws+C/4xw0cVIDgtHDWJ7VlYT6nuyNx
	ac6iKby6Iwvoc/XjTgS/1bbYw1qaftgfCcu19iiDkxD8SeH01mRzDWd2RBdfm6ALFjw==
X-Received: by 2002:a17:902:4324:: with SMTP id i33mr819758pld.227.1550068866032;
        Wed, 13 Feb 2019 06:41:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaCaG/gFlweCbdB60oeaU4AmzaVWmS4cSAgW+lLUALyHTKzFPqMTwrQSBH9Nn0hasD7HLSI
X-Received: by 2002:a17:902:4324:: with SMTP id i33mr819706pld.227.1550068865140;
        Wed, 13 Feb 2019 06:41:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550068865; cv=none;
        d=google.com; s=arc-20160816;
        b=ebbZR+djlsoAjOQ0vpBrRR7xV+WzIBzE3gEDMmJSiJfxGQrxhm/tQP4bT69BeHNgZj
         CHMLY2LMjGSISs/JjGh9YPCnAxtYM54LHlA/QaTMu74uX6eBJFdYEKedwzWpIzLGmHTn
         O7EWB2nSR61nWsihhlJE4YdfO03GhVFHDC3dMcB8450r8N/eBbLta7QyC9FvLAOzSAVZ
         yyR6/gHjhea/q5yYMmYezKg8DgJ2foiT08Zf9AF8hEVWTgKCXPttZq/+7rLo+t9L40qP
         tip3eRVUmmoZC0PIa6LGH7Vy6TgmRODfRxLfyyjGiOk0yi94WuS/gKtPyTMDpNW+UGY0
         PN1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nvlwPyQYARni0b3cZG9bzQyjlrPfoDOryJPlL9uYpF0=;
        b=mhztDyjRz10TPhymTHq5cAtaQlN02BCGZ2+sPv3Pa2x+ML8ywlaES02kckfsAIbhc0
         SuivSrwyYPZMZGU1VzeZ8Av3JfdNKqbT20rPKkq0CpqoT67sHuwg4mUnLGCAFimqwsy+
         Pva1HUmR6IB1ny1I1xO8qizqbx9Y3o0PzeoBn+1Uf1pLiP2iUVxsJw42oRm6WnHINpcq
         HTA6ffs9nqFjIx7uGUqYeZvZDtJHB+4l+S+FZ+FzWMp2NjBHSkeipLMZjGsHicVWc/kc
         367sdXZ+g1AhkXz28IRl1nGuTv8+5mKx0u1PemKnB4g5ZLHbFxRFZTbB978e+wcRbZpo
         Bc4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n15si11776065pgv.96.2019.02.13.06.41.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 06:41:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 641C7ABCE;
	Wed, 13 Feb 2019 14:41:03 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id D94551E09C5; Wed, 13 Feb 2019 15:41:02 +0100 (CET)
Date: Wed, 13 Feb 2019 15:41:02 +0100
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190213144102.GA18351@quack2.suse.cz>
References: <20190212183454.26062-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212183454.26062-1-willy@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 10:34:54, Matthew Wilcox wrote:
> Transparent Huge Pages are currently stored in i_pages as pointers to
> consecutive subpages.  This patch changes that to storing consecutive
> pointers to the head page in preparation for storing huge pages more
> efficiently in i_pages.
> 
> Large parts of this are "inspired" by Kirill's patch
> https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>

I like the idea!

> @@ -1778,33 +1767,27 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
>  
>  	rcu_read_lock();
>  	xas_for_each(&xas, page, end) {
> -		struct page *head;
>  		if (xas_retry(&xas, page))
>  			continue;
>  		/* Skip over shadow, swap and DAX entries */
>  		if (xa_is_value(page))
>  			continue;
>  
> -		head = compound_head(page);
> -		if (!page_cache_get_speculative(head))
> +		if (!page_cache_get_speculative(page))
>  			goto retry;
>  
> -		/* The page was split under us? */
> -		if (compound_head(page) != head)
> -			goto put_page;
> -
> -		/* Has the page moved? */
> +		/* Has the page moved or been split? */
>  		if (unlikely(page != xas_reload(&xas)))
>  			goto put_page;
>  
> -		pages[ret] = page;
> +		pages[ret] = find_subpage(page, xas.xa_index);
>  		if (++ret == nr_pages) {
>  			*start = page->index + 1;
>  			goto out;
>  		}

So this subtly changes the behavior because now we will be returning in
'*start' a different index. So you should rather use 'pages[ret]->index'
instead.

> @@ -1923,26 +1899,21 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
>  		if (xa_is_value(page))
>  			continue;
>  
> -		head = compound_head(page);
> -		if (!page_cache_get_speculative(head))
> +		if (!page_cache_get_speculative(page))
>  			goto retry;
>  
> -		/* The page was split under us? */
> -		if (compound_head(page) != head)
> -			goto put_page;
> -
> -		/* Has the page moved? */
> +		/* Has the page moved or been split? */
>  		if (unlikely(page != xas_reload(&xas)))
>  			goto put_page;
>  
> -		pages[ret] = page;
> +		pages[ret] = find_subpage(page, xas.xa_index);
>  		if (++ret == nr_pages) {
>  			*index = page->index + 1;
>  			goto out;
>  		}

Ditto here.

Otherwise the patch looks good to me so feel free to add:

Acked-by: Jan Kara <jack@suse.cz>

after fixing these two.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

