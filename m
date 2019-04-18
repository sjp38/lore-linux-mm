Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97C5BC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:04:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 636FF20674
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:04:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 636FF20674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00F216B000E; Thu, 18 Apr 2019 09:04:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F027B6B0010; Thu, 18 Apr 2019 09:04:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E18796B0266; Thu, 18 Apr 2019 09:04:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 964D46B000E
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:04:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f7so1218546edi.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:04:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kbxxXj0ov114ceXUHBFdk9QRM11dAfW4FOUL2T2L/Bo=;
        b=FesEkeAos+Lf3L9S9AnkSoDX4uaaArpDxFxLf2qPMAMF+mY8G7JrW6LHsGhb1U5GXl
         I9LrZrQGrfFs3A3zUU8wgrrLrihHsLXRPamXMCzMydg8dU5GtA0DYNKByR3Irgd6ADOC
         qVYGEFML2SmMpypGI2BGkcCe16heyTNR9hKadAeNL/QkjjzSaDiUojEQG65xbERRT5f4
         3hPK4urhvrtJo2djvDW1c9oMUvbOpxYxEWoaVucseuYwSQ8Fvve/ys8SkAhDJ+v3BRsj
         RHkb65jrxNznkGYSD2schF0pWIUF+1Pj8vkZ7KLCVBgneO2XMX0APYx3OkEQFYju0RrM
         dJdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAVyv5G15U85Ws75Nha5w8tYv7EFZsSE9Imz5QG39SEyjSR3nRFp
	ZwBLEaZj8+yKrU1oaKPF/yfG6lcqjoSYZT89iFQV5od3b+IRGpnO5V+wtTG9NKrCDScgzKBf/hc
	nthLfZjx9RnbD3FepjulCf60DrTQwNzninHKC15aJoZAycP2fWlgtxfDeSoeyieZPDA==
X-Received: by 2002:a17:906:1851:: with SMTP id w17mr50717305eje.242.1555592667153;
        Thu, 18 Apr 2019 06:04:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgX17tpgFhLScLnBSvlTohCMt3fRFbdeEHmQ+MhC0lao5/Hex0ClqMv+OhkyPp++6vlWa9
X-Received: by 2002:a17:906:1851:: with SMTP id w17mr50717269eje.242.1555592666325;
        Thu, 18 Apr 2019 06:04:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555592666; cv=none;
        d=google.com; s=arc-20160816;
        b=Uyss6eVeKL9fYQtL7NztdgySpzIsfNSPX223IA+nlvs5FzH6XUNKHf5b1SO2c+ol13
         otzHImTdHKxja0ryN7/6rRtozD0e+YqVnCL9mqW2bt79311JJpMp/NHALZxm3ITrrill
         qiuueYTi8yJDFUnJxUyha2VO83BU9yvDVmlFyzqMOQbwALZUgp5jmjibNdxL2f58lC7B
         dnFMDd6SjshA4+7z2ZdEx477vTXmUC8y2xMxr7j0HN9tvfaRGMUoBIYYsMmhfz5DBsFF
         RM/cDuazlAS7zCQbWHzHKhbi22Uk0kDpiLjRGqTjDiKc6v5s5lgjwdyAgYfBeDegwwHl
         s/DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kbxxXj0ov114ceXUHBFdk9QRM11dAfW4FOUL2T2L/Bo=;
        b=bSabzKLwdUgdbDnrOb2rpY1cahfOoJ1o6GedPsYozUeRFvSFBR01JWhhx9hSfd330p
         GmJXiUK6/k0IUEnbt/KNTcHi21su4W35hBjlpDSa/p3t2EhsS8Hc8qkac4fVPAkHJJ0b
         FEXLnNYq35vxg3gFtbEekKWQptFn8HDMLxOY2WmbVjTh3BJfppOk5IpnfqHD7YMzL3f+
         O0MImodLzAlj7ywU0o7QWueiNvnAbURk7bX0yVXJOTEQcAc5tAupPapsYadANjhz2r47
         BuKqLsg6a6vUJeKjLemtIQPEpkszbHoeBWMbzbnfwrIpSjLE/IZzoEJQd5SNykXY9X+w
         QiIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o26si942898edc.138.2019.04.18.06.04.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:04:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C2C60AF68;
	Thu, 18 Apr 2019 13:04:25 +0000 (UTC)
Date: Thu, 18 Apr 2019 15:04:24 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/page_alloc: remove unnecessary parameter in
 rmqueue_pcplist
Message-ID: <20190418130424.GK6567@dhcp22.suse.cz>
References: <1555591709-11744-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1555591709-11744-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-04-19 20:48:29, Yafang Shao wrote:
> Because rmqueue_pcplist() is only called when order is 0,
> we don't need to use order as a parameter.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f752025..25518bf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3096,9 +3096,8 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
>  
>  /* Lock and remove page from the per-cpu list */
>  static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> -			struct zone *zone, unsigned int order,
> -			gfp_t gfp_flags, int migratetype,
> -			unsigned int alloc_flags)
> +			struct zone *zone, gfp_t gfp_flags,
> +			int migratetype, unsigned int alloc_flags)
>  {
>  	struct per_cpu_pages *pcp;
>  	struct list_head *list;
> @@ -3110,7 +3109,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  	list = &pcp->lists[migratetype];
>  	page = __rmqueue_pcplist(zone,  migratetype, alloc_flags, pcp, list);
>  	if (page) {
> -		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> +		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1);
>  		zone_statistics(preferred_zone, zone);
>  	}
>  	local_irq_restore(flags);
> @@ -3130,8 +3129,8 @@ struct page *rmqueue(struct zone *preferred_zone,
>  	struct page *page;
>  
>  	if (likely(order == 0)) {
> -		page = rmqueue_pcplist(preferred_zone, zone, order,
> -				gfp_flags, migratetype, alloc_flags);
> +		page = rmqueue_pcplist(preferred_zone, zone, gfp_flags,
> +					migratetype, alloc_flags);
>  		goto out;
>  	}
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

