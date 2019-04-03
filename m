Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03C6CC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:46:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDAB1206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:46:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDAB1206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5326A6B000A; Wed,  3 Apr 2019 04:46:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E2846B000C; Wed,  3 Apr 2019 04:46:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F86F6B000D; Wed,  3 Apr 2019 04:46:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E59F06B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:46:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d2so6993904edo.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:46:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kNM4l9bXEKc69j1pB0i3a3h64z664l/8zeyUzMxsLG4=;
        b=flWq/2L/+dP5MGJF5Mk8mK2OBXRG4Vc0q9JCDrfQ8do2ZSZ5R6lzMKlhLr64YPYBpS
         Sory/dAal9QN6ux8SLfbCfBieLxCfoOhAClRs3hjpjgVN6EY0/KdGrVrPr1NFIzY06er
         Yx+9ShFgCgBmtbYCjbJbH846ZHN2tky+QmCoVwrsF0VnOOhMeNJSd6x7tj8arKj5LNKX
         KHb9OnXfz8G+KHaBIkOwSJ5laWib/PaIcrnPwFKrO9E2mklwLbSEiC5mkbqS9bdQOCk7
         kMvKiaE893yMsLBDGEQrVZAj/Qd1ANIXY/MEkbi9bTnDI0V9JlebsA2qdxTLSOSLh7+v
         ntSA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVEyfli7dFuK39mCkiCiueXzAoDEJtDui52RqdRE9z8lVKaU+Sr
	G7NL2D5FHfPU6h3u4htReSralmudc/tZVAzyIU/vnNuHoD2c88IDI8OarJ4Oh6Q4Qzt/7/Mvoyi
	kynd+9IAQptdOj5D6LqM1VFwSZSTZ0At4yHn72LLaU7XPcJjnWu8XCiJo4x7J7BQ=
X-Received: by 2002:a50:9767:: with SMTP id d36mr5654683edb.41.1554281165457;
        Wed, 03 Apr 2019 01:46:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbnM9AIbWsPkB3XCVZwj02OGUGoAYz7xOJr5qyGY69r2BfcBfj2/SRTgKgGO664oxNXsLc
X-Received: by 2002:a50:9767:: with SMTP id d36mr5654649edb.41.1554281164751;
        Wed, 03 Apr 2019 01:46:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554281164; cv=none;
        d=google.com; s=arc-20160816;
        b=pObknytENRpzep0+fsHeiWY+eWnnfvPp7ivDQ4tKSQVrdriFWWerSZLUKWivKzVTd/
         d2zci225Y9p6CBlGBYGob8dE555BjFpqfuIzIceVdbYnIGNAupBCkQxgoO8N66S73wJ9
         eDdyjoB14zyvSYRHHVF+JH65FrRlF7CyV1U1KAgxrPXtMFaaYp0XzjuW6eYCTC+BolbH
         p2n+gsOWcRL4kyCIbjV1+Ox8PtAvUt2JVHQM4UQTSf1MGOQPxl/6uUjoRz5980t5khe7
         sZeaIJA1k3N+s+LsvPrGmdh/3rqQhaGl9B6/l8+glcIxmpRQ+bb5dijD7PeV2/9RK4UL
         Wqqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kNM4l9bXEKc69j1pB0i3a3h64z664l/8zeyUzMxsLG4=;
        b=mXOdQC5A+mycTymfO1xf64fSnWRsxsvxCoLSRlHZ3ZmyoAwe4zQMernIaTNoNAm5VI
         IU+fhZOwCNL2UMvGbUg9cWQwGAF13otRcXc7Fkrih6H0yDkYPTEGkUs1ZOyRUUUlvziU
         Hn7hUGDRI9YVKXKb+tq3r2isNsRg4ljrCJWE9sTyfmXVmajRAsjnJU5ELsN3KJJeAcem
         kkyojoNXGjbUJXLTw+BmFgxVfoJ8LkGygyOWhICb4XEUyKTZYVYLCEOIgSgtwHGYX5q4
         Qso5B45O0cxBMrOfbQbaya/ArpAZN8yt9isbcwfTFxYazpSYlDR1wZjr/b/onBp2egks
         CPow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dt14si878497ejb.361.2019.04.03.01.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:46:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 545D3ADA3;
	Wed,  3 Apr 2019 08:46:04 +0000 (UTC)
Date: Wed, 3 Apr 2019 10:46:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, david@redhat.com, dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190403084603.GE15605@dhcp22.suse.cz>
References: <20190328134320.13232-1-osalvador@suse.de>
 <20190328134320.13232-3-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328134320.13232-3-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-03-19 14:43:18, Oscar Salvador wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> arch_add_memory, __add_pages take a want_memblock which controls whether
> the newly added memory should get the sysfs memblock user API (e.g.
> ZONE_DEVICE users do not want/need this interface). Some callers even
> want to control where do we allocate the memmap from by configuring
> altmap.
> 
> Add a more generic hotplug context for arch_add_memory and __add_pages.
> struct mhp_restrictions contains flags which contains additional
> features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
> currently) and altmap for alternative memmap allocator.
> 
> Please note that the complete altmap propagation down to vmemmap code
> is still not done in this patch. It will be done in the follow up to
> reduce the churn here.
> 
> This patch shouldn't introduce any functional change.

Is there an agreement on the interface here? Or do we want to hide almap
behind some more general looking interface? If the former is true, can
we merge it as it touches a code that might cause merge conflicts later on
as multiple people are working on this area.
-- 
Michal Hocko
SUSE Labs

