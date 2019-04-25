Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BDA5C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:43:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26246217FA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:43:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26246217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C2C76B0005; Thu, 25 Apr 2019 04:43:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7738C6B0006; Thu, 25 Apr 2019 04:43:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 664586B0007; Thu, 25 Apr 2019 04:43:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13CB76B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:43:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s21so11312454edd.10
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:43:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6bCTRhaJZcHleBm+PC1JlrZO4wAxSCu2khUzsJ1UBUs=;
        b=unfXQhxADGeSbFpfg3whXIAmkYTUH/2Ceo/5W1fmJppoAkYD+esA0xHZY5wkNCL024
         OZSAdw7e36+49jmb9fEz1yoICe4EtIbyAEOzsSjXRK/D5RzWpIo+0+W/ddiPG74rQCe7
         WT6AYFzzKYGJ0LfZJOFdR+tQNEQQJQtr3Y9JU6JzGH8bi8EZ1ciReHh8rnBEYuBtBGbm
         YRG1loncGcfITOeZPJapKfo7SUNu6hfTpLvcaMpP6GtqwA+T/B1h2cswt5Cgl0qcFp03
         2329ZU1RxSur+ZmB09kdLiQxwLWb4KjTsMRSQyGO7hg4oFmtiEd6rkMymyNxv6IyZvig
         rdMw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWA3tO5x2WpB3wUyZg10ItkP+LjUO/xqw5e9zXWyKTH4MZnI9RE
	O7I2OrjPoS78Ew5Ck8pmwA8nkbAlRATUbWlP9xIDtivl12DeHLlaGCjEdquSpYSRU1m9Giymubd
	Q9EwDGYOmgoQgbfWXMjW1K9pVL47FSLgvqvlImEBgAHzjMtNTWtAHxGeccuDtDhI=
X-Received: by 2002:a50:89b9:: with SMTP id g54mr22346168edg.37.1556181785557;
        Thu, 25 Apr 2019 01:43:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXhblkermAnQdiW/y2qj4dgWHi0nUkIXRHEeeUOx1P3K1OFQX98n7B89+x8hbO2KplR67W
X-Received: by 2002:a50:89b9:: with SMTP id g54mr22346114edg.37.1556181784539;
        Thu, 25 Apr 2019 01:43:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556181784; cv=none;
        d=google.com; s=arc-20160816;
        b=fUTKz9TvuBsOI55SZNSo9QZZi1RjBCq2erhbCDEwhWfacEBo0oGfB4Iru51xmJFpVz
         I1L6bj6pdCnLOIMlZ2xeg767IVON5oBjFLWwdALjmUWieLTw85TIdi9g+UW0SjqKmJRC
         l6APlZXt5cJRDjwpbzCrvGu2eVW1z3D3IjP0eYx5GuwPUx0eL6j3PDCCvVRSiTNfX2z5
         Dl0hs4ofITMxNHp8y9wsUtDNbnE/ktFfVM8z8wxfQMU+z+WtPR1XTRIhQI04/hKAmA4F
         CVD2hIzseSuQLnLWzicY3eSMW+vpShGWe8J9RwsumiPUdAfNtP8QxbCpiGUhD0W/bHTO
         44kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6bCTRhaJZcHleBm+PC1JlrZO4wAxSCu2khUzsJ1UBUs=;
        b=HimuLXszl3Zh0yrssYZxzHz7XHTZ44xgToVkwhCj5Dpn5z3WKzq2nBf0k8MYyzihzf
         ePqayA+dLGMtFJjFptZfFNZ7yTRxjPvsLEKWQ4cbdzeJvOkgM4ypDw61cmx0N+vaUGGn
         DRIVqT93fOpFQcI19jr6xHT7kZVTD6YthbkLULxv6I43RkumO45BoCbK+B2bD0w6uC1e
         kAtoIO2wEJ+rG+4ozFBRqc3SEXkjxPpmKUlS6VWjHZMVJaLycbw+IHYPjkQIbUnrUqzK
         qo4236X6DMxY6TEVNjAKxftBQC+1bx9MXmhDqrznu4P7xuykXCK1EYTf7f7YhpUF+14q
         02wA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4si1439721edh.33.2019.04.25.01.43.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 01:43:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A9156AD18;
	Thu, 25 Apr 2019 08:43:03 +0000 (UTC)
Date: Thu, 25 Apr 2019 10:43:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Du, Fan" <fan.du@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"Wu, Fengguang" <fengguang.wu@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
	"Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Message-ID: <20190425084302.GQ12751@dhcp22.suse.cz>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <20190425063807.GK12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F04@SHSMSX104.ccr.corp.intel.com>
 <20190425074841.GN12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F50@SHSMSX104.ccr.corp.intel.com>
 <20190425080936.GP12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785FA5@SHSMSX104.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF067884825785FA5@SHSMSX104.ccr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 08:20:28, Du, Fan wrote:
> 
> 
> >-----Original Message-----
> >From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> >Behalf Of Michal Hocko
> >Sent: Thursday, April 25, 2019 4:10 PM
> >To: Du, Fan <fan.du@intel.com>
> >Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
> >Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
> ><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
> ><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> >Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
> >ZONELIST_FALLBACK_SAME_TYPE fallback list
> >
> >On Thu 25-04-19 07:55:58, Du, Fan wrote:
> >> >> PMEM is good for frequently read accessed page, e.g. page cache(implicit
> >> >> page
> >> >> request), or user space data base (explicit page request)
> >> >> For now this patch create GFP_SAME_NODE_TYPE for such cases,
> >additional
> >> >> Implementation will be followed up.
> >> >
> >> >Then simply configure that NUMA node as movable and you get these
> >> >allocations for any movable allocation. I am not really convinced a new
> >> >gfp flag is really justified.
> >>
> >> Case 1: frequently write and/or read accessed page deserved to DRAM
> >
> >NUMA balancing
> 
> Sorry, I mean page cache case here.
> Numa balancing works for pages mapped in pagetable style.

I would still expect that a remote PMEM node access latency is
smaller/comparable to the real storage so a promoting part is not that
important for the unmapped pagecache. Maybe I am wrong here but that
really begs for some experiments before we start adding special casing.
-- 
Michal Hocko
SUSE Labs

