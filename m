Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DCCCC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:56:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E514C20872
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:56:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E514C20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B27C6B0003; Wed, 17 Apr 2019 09:56:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 862B36B0006; Wed, 17 Apr 2019 09:56:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 752916B0007; Wed, 17 Apr 2019 09:56:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25D0D6B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:56:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h10so4758663edn.22
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:56:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TraM4FQnBF+bIfFBpIL4h+VJ0VC/x7K9YyphSQVJJ6w=;
        b=if/hz3UQdG8aEoLQVbYhbvQBrY8d9GsxE7xhV9WJg3e10fyQAzokC+morw8JO6tVt7
         UBggMjKV0OMV3UWdK97UGKGp7XLP+A10PV6fKxxMs1V6YJ5EfSIQawdN7+Da6OGiKysN
         /VREaDyvD8RgwxlWuYtARt7erdkbqr0XADbW34A6meqrG1D/iOJgjOzNK7LAlq6UcZ4P
         K7w6wDz9PNuFnBnR5fnY2/3Km6sTloEWcXgQrGzEDcIjqQzZhADe8p1rr6Ivhvkr9jof
         sMf16A6Hi81QTLN/2rPNvFpXItGcA7E/TFfBiHCD+f6QS2hSZuBM2TvPV+sFcl2rvHaU
         k3HQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWrwUQRdgNdzr3hhis4rCcVn/RSDU6KX0Ot8B9e07QHuNqehAR/
	jq+eaTnEqny3ySDHJqJpdsTzGEKFH+xHpZK76oT80mnK+p+K8n0QJs0EjUKoJCuri8Cxu2OZABq
	eISniNUsHwASHig6S0Jfao5fFYiqpBOjR9NnTm/hXFQTz++Y2xG5qvgpfrqrxQMPTHA==
X-Received: by 2002:a50:8ecb:: with SMTP id x11mr19474369edx.88.1555509397706;
        Wed, 17 Apr 2019 06:56:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+6CpXcAzHL/ihWE5tVDajLg/VZATgoWcJuZW/Fnph/+3cSmJGtcI/lEnniroTdCeqJtOJ
X-Received: by 2002:a50:8ecb:: with SMTP id x11mr19474326edx.88.1555509396885;
        Wed, 17 Apr 2019 06:56:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555509396; cv=none;
        d=google.com; s=arc-20160816;
        b=qkc1t99/OEWJTXjMFqgtmsvGpXE5jmeuYPK0ejIeXLQuQ28xjRGOtXuDmtAddHakiV
         ZcsGd/PeD3QpFQOol5YbTR5vP372rYBkw+oBdFODNrpSDy3xW3O7NbhT5AB6CXSsfema
         UDFCswli3cRzbl+jPZTWWXqCcKj5+kXvufEONvZovfxPj46f+QGaVGyMMAWlNpjQfiqP
         AB5cL7EG/VWEXTfXNHuUfO7XPD/1LArlN7uX5kgQBK25o1xx4d2KwHbPtPdHn7XQL+bo
         5tVE6Uima39UGfujUAFhLgUmqSF1JJg9ZLFzmIgJQHwpZv+495PUu0mOWAlcdSAsqBin
         /G7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=TraM4FQnBF+bIfFBpIL4h+VJ0VC/x7K9YyphSQVJJ6w=;
        b=W0/SUwpakm474ybU58Uj/Ws599fU4w6F6YgIo9L6oaVM3SyeVmY2Zp9MlPSuWCEAhR
         CLpa/roMM5gK7EsEhLJ2vgXMOoILz42nRj6jQZSLmSR+DTCHG5trZXmEKPkgxgqYjp4K
         KyvC4qmmxeRdgjh/EzaL7VNtBI+yp9U1k/RixAT50OqKxBh7EHZOtPNoZ9nNMjiPRbrd
         dW40L2KLGmbnl0s0qs/lWzf/BnNA5DfMOoB9w9XfYhWOCEY05HR5unPZjrVwX9Fp7iHX
         ikaC3roP0pTym30kOiJ1NKJxRoyyEoztLhcs7bVDIFzirVBks8wZKPeU84QOlMD1Jg5s
         MsDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj17si7400982ejb.342.2019.04.17.06.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:56:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8794BB177;
	Wed, 17 Apr 2019 13:56:35 +0000 (UTC)
Message-ID: <1555509378.3139.35.camel@suse.de>
Subject: Re: [PATCH v1 3/4] mm/memory_hotplug: Make __remove_section() never
 fail
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
  Michal Hocko <mhocko@suse.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, Wei Yang
 <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>, Mathieu
 Malaterre <malat@debian.org>
Date: Wed, 17 Apr 2019 15:56:18 +0200
In-Reply-To: <20190409100148.24703-4-david@redhat.com>
References: <20190409100148.24703-1-david@redhat.com>
	 <20190409100148.24703-4-david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-04-09 at 12:01 +0200, David Hildenbrand wrote:
> Let's just warn in case a section is not valid instead of failing to
> remove somewhere in the middle of the process, returning an error
> that
> will be mostly ignored by callers.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Just a nit:

I think this could be combined with patch#2.
The only reason to fail in here is 1) !valid_section 2)
!present_section.
As I stated in patch#2, one cannot be without the other, so makes sense
to rip present_section check from unregister_mem_section() as well.
Then, you could combine both changelogs explaining the whole thing, and
why we do not need the present_section check either.

But the change looks good to me:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/memory_hotplug.c | 22 +++++++++-------------
>  1 file changed, 9 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b0cb05748f99..17a60281c36f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -517,15 +517,15 @@ static void __remove_zone(struct zone *zone,
> unsigned long start_pfn)
>  	pgdat_resize_unlock(zone->zone_pgdat, &flags);
>  }
>  
> -static int __remove_section(struct zone *zone, struct mem_section
> *ms,
> -		unsigned long map_offset, struct vmem_altmap
> *altmap)
> +static void __remove_section(struct zone *zone, struct mem_section
> *ms,
> +			     unsigned long map_offset,
> +			     struct vmem_altmap *altmap)
>  {
>  	unsigned long start_pfn;
>  	int scn_nr;
> -	int ret = -EINVAL;
>  
> -	if (!valid_section(ms))
> -		return ret;
> +	if (WARN_ON_ONCE(!valid_section(ms)))
> +		return;
>  
>  	unregister_memory_section(ms);
>  
> @@ -534,7 +534,6 @@ static int __remove_section(struct zone *zone,
> struct mem_section *ms,
>  	__remove_zone(zone, start_pfn);
>  
>  	sparse_remove_one_section(zone, ms, map_offset, altmap);
> -	return 0;
>  }
>  
>  /**
> @@ -554,7 +553,7 @@ int __remove_pages(struct zone *zone, unsigned
> long phys_start_pfn,
>  {
>  	unsigned long i;
>  	unsigned long map_offset = 0;
> -	int sections_to_remove, ret = 0;
> +	int sections_to_remove;
>  
>  	/* In the ZONE_DEVICE case device driver owns the memory
> region */
>  	if (is_dev_zone(zone)) {
> @@ -575,16 +574,13 @@ int __remove_pages(struct zone *zone, unsigned
> long phys_start_pfn,
>  		unsigned long pfn = phys_start_pfn +
> i*PAGES_PER_SECTION;
>  
>  		cond_resched();
> -		ret = __remove_section(zone, __pfn_to_section(pfn),
> map_offset,
> -				altmap);
> +		__remove_section(zone, __pfn_to_section(pfn),
> map_offset,
> +				 altmap);
>  		map_offset = 0;
> -		if (ret)
> -			break;
>  	}
>  
>  	set_zone_contiguous(zone);
> -
> -	return ret;
> +	return 0;
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
-- 
Oscar Salvador
SUSE L3

