Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F141C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:49:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 066F820883
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:49:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="voYT0mE2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 066F820883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A3266B026F; Wed,  5 Jun 2019 17:49:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 953066B0270; Wed,  5 Jun 2019 17:49:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 843476B0271; Wed,  5 Jun 2019 17:49:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC6C6B026F
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 17:49:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u7so225245pfh.17
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 14:49:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0AHEWITpV6DiHVwFl8kRvKAjquJlUVPVbr6sr1gCdPM=;
        b=pgFNHIkOrEjDXTdHAK9jtcmQawJbxsmutKc+NOWsoZppnZtzv+WBRoSFV+1QAt+4bc
         FpuxaMGC7va4ylwM8I3w8EeG6feMYp3gGq5VXBF3LYMFM841jKUlh6+8xKaTL7119wfR
         DCVz5ks2c/Nlc6s5eZ+YblH/e13IadD6XGZISLsdVIpuO3ctW0g0U2dQYIV6TkXUooh0
         l8ccXZXWAmvZDJtNbGOsEVVKLVnhivvj2ziwy7NqDiZrT8YURysbxJLIg4iqr6x2LOix
         26Wg13jTHeUoSbkTyvjbpXfE4zyFmgzNH5kPiwlSJrjpB8rR52KssBWwPuvITzRM0Ygz
         3rUg==
X-Gm-Message-State: APjAAAUUWHOw11sMTD7xQ00DuB65Ur3SH+CWapE0olZvUPSi8ksOhgc5
	2Ih01NdWuC8w4pZedbavwoRUxsmzzwfZZwC158D5qAJQ9Yh1KQveZ258P3bf71eU4YzqJGtx5yG
	VMngNzuDmO8GYeh2pOUT0w7s/GUmyOjqNjPxlpVnwMm/ANz0xxk80/V8eiQApKVY/Tg==
X-Received: by 2002:a62:5581:: with SMTP id j123mr49787131pfb.102.1559771353929;
        Wed, 05 Jun 2019 14:49:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbf7itTeMsKA8xxsiI0hx4yUJko7iUIVUTdedOTSlIyzZ5JkyjeZw4JdawpSfXHxb5J1yR
X-Received: by 2002:a62:5581:: with SMTP id j123mr49787081pfb.102.1559771353247;
        Wed, 05 Jun 2019 14:49:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559771353; cv=none;
        d=google.com; s=arc-20160816;
        b=UVl5b3UKpU2/EnV5waGTfxd9u1arC6Iv/9DUe2D7Vi4EWWmLKS2s+bm+GXTdpaRDWx
         W9Fr2dTmM4fWwbBXi2BUJNPMpCZevDq8RPfTwPX3zT90Mryaf6jLbyOVZlwSGqT0CnFO
         uqmNglyu6OS/abmAns9Rw7dTlb16E2N0GtZydyNcUusgWkiYqrkxqDoY+DAT55MGBtmD
         vobHW7YE72h0aQOkH5wwKsBsW/iRPj8RsmGzkVWemSgIBi6GNTXWeaENiWRWED5Rk3Bh
         Dglc4c8PZprd9YIHbtEJmR6LolzHy/JjCUxFPb952JVt3dwgTaot951IB/IGetEXj2bB
         RMtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0AHEWITpV6DiHVwFl8kRvKAjquJlUVPVbr6sr1gCdPM=;
        b=LAIx6ERa2Zfs7q4mcAHwbCksnDseBbiSnPC3iW7iofLldwJNIkGkbZYTEQ9Pe98qA4
         EtQCDYQiXNzzxAU7BlB1MH8V9QQbkx3gE/nTcT/UHcOJ5i+hOjk3sVG+58rupcQOXUkl
         rEfxSiPU5+dj8t60lG9GUGeW5cTSbFYsU6Kfuv+UADfUBjKn5mnCmnPh2WqQ0Iw+LcYT
         94fiPe496pMfwta1CKfc3+vMpvXIuoBfXQXZqbT4rs61LLSxJDuIhXWL41JfpMCYcbJy
         R+XeaUPRthoTVSNXzwaov5Go2QGh+Z35oVW11GCaBYD5QZL+TLhuMsbEcGDGOKPlovL6
         8ghw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=voYT0mE2;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y12si101570pgc.97.2019.06.05.14.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 14:49:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=voYT0mE2;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 92F662067C;
	Wed,  5 Jun 2019 21:49:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559771352;
	bh=o9XCwaZGzE63JH3BlHeLxlRN4g5v0bjuEKLTtVdRVy0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=voYT0mE2QFPaaXfMNidp8XKZzbdetXlW2uiRL+mWOB7xc4nLzric/yQRfNuPzD+hG
	 ltqSZsu4WPGkKl00DUSjIT3Z/2NtvKQLAI0yliqubD6O1B2ARXWZ6grl4zUSxZlkhl
	 ngSgZ0UkH+RQp0JVpDU8lm3O3ftfuUyH8Tk5OVyM=
Date: Wed, 5 Jun 2019 14:49:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>, Mike Rapoport
 <rppt@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Matthew
 Wilcox <willy@infradead.org>, John Hubbard <jhubbard@nvidia.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch
 <keith.busch@intel.com>, Christoph Hellwig <hch@infradead.org>,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-Id: <20190605144912.f0059d4bd13c563ddb37877e@linux-foundation.org>
In-Reply-To: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  5 Jun 2019 17:10:19 +0800 Pingfan Liu <kernelfans@gmail.com> wrote:

> As for FOLL_LONGTERM, it is checked in the slow path
> __gup_longterm_unlocked(). But it is not checked in the fast path, which
> means a possible leak of CMA page to longterm pinned requirement through
> this crack.
> 
> Place a check in the fast path.

I'm not actually seeing a description (in either the existing code or
this changelog or patch) an explanation of *why* we wish to exclude CMA
pages from longterm pinning.

> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2196,6 +2196,26 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
>  	return ret;
>  }
>  
> +#ifdef CONFIG_CMA
> +static inline int reject_cma_pages(int nr_pinned, struct page **pages)
> +{
> +	int i;
> +
> +	for (i = 0; i < nr_pinned; i++)
> +		if (is_migrate_cma_page(pages[i])) {
> +			put_user_pages(pages + i, nr_pinned - i);
> +			return i;
> +		}
> +
> +	return nr_pinned;
> +}

There's no point in inlining this.

The code seems inefficient.  If it encounters a single CMA page it can
end up discarding a possibly significant number of non-CMA pages.  I
guess that doesn't matter much, as get_user_pages(FOLL_LONGTERM) is
rare.  But could we avoid this (and the second pass across pages[]) by
checking for a CMA page within gup_pte_range()?

> +#else
> +static inline int reject_cma_pages(int nr_pinned, struct page **pages)
> +{
> +	return nr_pinned;
> +}
> +#endif
> +
>  /**
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:	starting user address
> @@ -2236,6 +2256,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  		ret = nr;
>  	}
>  
> +	if (unlikely(gup_flags & FOLL_LONGTERM) && nr)
> +		nr = reject_cma_pages(nr, pages);
> +

This would be a suitable place to add a comment explaining why we're
doing this...

