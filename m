Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E592C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 08:27:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0874A207E0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 08:27:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0874A207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6913E8E0002; Tue, 29 Jan 2019 03:27:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 667F58E0001; Tue, 29 Jan 2019 03:27:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 509BE8E0002; Tue, 29 Jan 2019 03:27:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E58F58E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 03:27:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so7639742edq.4
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 00:27:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LgZDcmTq/1lifOnM5bTOPVcmHHN7aHNWtQFrQu68yxc=;
        b=Pq6dGgJrHOOqlZicJMaeok39/TSdOpmB3W63ZiGLUkgGfbrnS0oChF3D54D8eyMXtg
         i5/oExJ7Do4l0EFR1kCoLBQ4NGa1N8pPWxGWslGGDWpMUx1vphIOBsb64N79LAokoufI
         CitJuLdZjfW5lTJ/qpAw5UxgXbVF2GmLV1B4ngFg2ksF/4zjtkVeN9dB3FdmcZv7+Aqe
         lBLUR3+Zj8hCOfuwkdPZ+QawNggciU9QoD3JXWwsjY5fhUvex7hSIuFrbvMts8kXHoUD
         /ZIRyZsAnXrvoQ6I13d+k7Pg5YyOTvAt4JUHzkW9B2N22Wk4FJwONmcvr6uTPV+vr7v3
         Ap+w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AJcUukdRj+A3I5Yt+Yq31QYqqVdp2eCrCePG6MGZSuhH5uvIPlBybyeC
	I0gwmFW6fRBXk9HD1diYdghYfheq5MjAvuFjqs80HarzdBjhjuVFzt8tiextoByswLDsuk/ORJV
	lfCSyDYPgUaw/hUz1eoYueDfVXWsBOXYVqAA9sNBHsv8J7EX1MOWFWwTypx8wlx0=
X-Received: by 2002:a50:ba5c:: with SMTP id 28mr24200149eds.91.1548750423480;
        Tue, 29 Jan 2019 00:27:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7w/5hD6zUc3y5KBxqS1zHX5ThHAq45Cf9WiGy2QkAYe56roySPQQ6Ovt4fwrGWyNVexJt9
X-Received: by 2002:a50:ba5c:: with SMTP id 28mr24200112eds.91.1548750422671;
        Tue, 29 Jan 2019 00:27:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548750422; cv=none;
        d=google.com; s=arc-20160816;
        b=ozsWGDp4U+fU1E7ZI451ZJ6V4hGIgsTvmWbGMBlKRW3Py5pKbEGHF4G9QbzrdI3ns5
         B10JP5gFF5U/lqipDSqlduFUIJAOZvOgZ2Y3pxoN8vNCf7cVahzpM24+bxUIpOJNcnGt
         J8f7voRHH4u1nfLX9z0nKAs+rvYB9mJ/2mLVdfxBnCElCh0+qe511k19vl0oNzl60fOJ
         OVQrPbXBbXsiUYia6JaluskAbkOQV0aRumCXOPnlK2Ur7Vy1fO6f/cPQIfYWqpOTcMd/
         tXIX0TB38OuBRLnLMWqO/gtGPVXCwDVDgBd7MTS1MmmhO9W41Vzu0UvL2WcrKfyb3l00
         0IGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LgZDcmTq/1lifOnM5bTOPVcmHHN7aHNWtQFrQu68yxc=;
        b=IRksfdBvB4qXttT5h0cNu0WEQPzZo65RaRvtKqRBVliBKnVbtoq7HYqVQGCJSSkuuZ
         JeKPKervQYVzRFAsyDu34XilEum6CWIoUUSEHwV9y4Ux2BTOfmyCnqQjTw9LH92w+TCc
         jeBWEAAfsi0G1j5UHbFGFiSSmK6N3x2/zQaWIT6nVZ116YS6USeylWl6O1jz+o2DJSe3
         1CpwHa/A5gnoqf7zYdScoRhLKstAyuXAD3fHnH1f+PMinzcT6e/UNmxVPMWz0Dk+Dk48
         3g5cP8TtMoG8MJcj5x3GEEpdHJ7Po4E/Xybx9PIGs1mP3dqEARv5M9NbKzIZFvLGIEbr
         Nnjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id j12-v6si1954492ejs.69.2019.01.29.00.27.02
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 00:27:02 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 73C3940AC; Tue, 29 Jan 2019 09:27:01 +0100 (CET)
Date: Tue, 29 Jan 2019 09:27:00 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, mhocko@suse.com
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
Message-ID: <20190129082658.erftot43e5ogasif@d104.suse.de>
References: <20190122154407.18417-1-osalvador@suse.de>
 <5368e2b4-5aca-40dd-fe18-67d861a04a29@redhat.com>
 <20190125075830.6mqw2io4rwz7wxx5@d104.suse.de>
 <20190128145309.c7dcf075b469d6a54694327d@linux-foundation.org>
 <20190128145617.069b3a5436fc7e34bdebb104@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128145617.069b3a5436fc7e34bdebb104@linux-foundation.org>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 02:56:17PM -0800, Andrew Morton wrote:
> 
> --- a/mm/memory_hotplug.c~mmmemory_hotplug-fix-scan_movable_pages-for-gigantic-hugepages-fix
> +++ a/mm/memory_hotplug.c
> @@ -1305,28 +1305,27 @@ int test_pages_in_a_zone(unsigned long s
>  static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  {
>  	unsigned long pfn;
> -	struct page *page;
> +
>  	for (pfn = start; pfn < end; pfn++) {
> -		if (pfn_valid(pfn)) {
> -			page = pfn_to_page(pfn);
> -			if (PageLRU(page))
> -				return pfn;
> -			if (__PageMovable(page))
> -				return pfn;
> -			if (PageHuge(page)) {
> -				struct page *head = compound_head(page);
> +		struct page *page, *head;
> +		unsigned long skip;
>  
> -				if (hugepage_migration_supported(page_hstate(head)) &&
> -				    page_huge_active(head))
> -					return pfn;
> -				else {
> -					unsigned long skip;
> +		if (!pfn_valid(pfn))
> +			continue;
> +		page = pfn_to_page(pfn);
> +		if (PageLRU(page))
> +			return pfn;
> +		if (__PageMovable(page))
> +			return pfn;
>  
> -					skip = (1 << compound_order(head)) - (page - head);
> -					pfn += skip - 1;
> -				}
> -			}
> -		}
> +		if (!PageHuge(page))
> +			continue;
> +		head = compound_head(page);
> +		if (hugepage_migration_supported(page_hstate(head)) &&
> +		    page_huge_active(head))
> +			return pfn;
> +		skip = (1 << compound_order(head)) - (page - head);
> +		pfn += skip - 1;
>  	}
>  	return 0;
>  }

It looks much better, thanks a lot for the cleanup Andrew!

-- 
Oscar Salvador
SUSE L3

