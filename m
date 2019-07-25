Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9FA9C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:13:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C8B22173E
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:13:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C8B22173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3394A8E0062; Thu, 25 Jul 2019 06:13:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E99B8E0059; Thu, 25 Jul 2019 06:13:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D8F38E0062; Thu, 25 Jul 2019 06:13:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C41178E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:13:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so31857214edt.4
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:13:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Z99G27Lzy67exZmkSSgaAeEp5wxfmyOARbAWmkyC0fM=;
        b=NwkV9/epPTN9+p/0xjk2D+1tvBxdV7pxBiMjNHH22k401e8ZNC83AQynWiBqHAw/zq
         OYseyWcwjkFYiKIgvLbeCfFMtNvsuityrhClBLLbQIP/U96bsPXlfp8tLs6b4vTtsnhv
         2KiI6QZZDSKNzCHjdHdvrUzmGCskvjS/njdN5kWjU3Uuw9G269Yme25LtBlRlrwpEHtJ
         dnIvgYLT7t4NtDVetHdrTTXOMjw2B1LrF07a5w8RGvIvXnnrcCDbyZIBhHYARCdcOnUM
         O0wz981NGIXDvOVEF9oxXRZEWBt2431nsWvE0y6EnnZ3llYRrRyxHpbYBleOvg4e7K9Q
         2QAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWYD30CnniI+VtpxsLacc5G7lAInnubTC3GjRUunVG+BaMX5Yz8
	/cCPVg1yw6t4O90sgFpmZPhcyc37fWzWIfKWp5ii4Q80Z9B49JTSLQGPcpImPQEG8WnKiYciwWC
	TFtTru/X3YwnmnOpOAC3hOckIfklZFvgffxTuWHBMHdqA0a+lGmVriOQok0OW+pGe1w==
X-Received: by 2002:a17:907:2101:: with SMTP id qn1mr68154654ejb.3.1564049611364;
        Thu, 25 Jul 2019 03:13:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHhvGKVEMLbHuS7HnDi9u72ftpB/jdh6e3PTCHVdpMSFuXigPvQvIwprh/r9XFRoEP1ebS
X-Received: by 2002:a17:907:2101:: with SMTP id qn1mr68154608ejb.3.1564049610693;
        Thu, 25 Jul 2019 03:13:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564049610; cv=none;
        d=google.com; s=arc-20160816;
        b=RH9j1QE17RfYioOZji1OSz6BGq6TKpPh207Bof5yDXo/Vdw5uwfFlonGPlz1cqgf7s
         /UFMnZAs+KBagxqq4wnDk54nXn3CDHkaIKxXihilMVOa+Yl+ZK2GAxxSY1saszIYlNr8
         jVjzLjz8l7o8IJ538cdHAB5UEe38gJDdQx17RahYZQg+FHvzDaqnlOfMAOaJ0NVPutoG
         EhVkzg4Crsg6jjjPuY6p2pWxWIBfNdPGRs5tjeJWuaHsQEZK/ykb2nR9T6rb3bLXOndp
         A+Tz5J4mSKPSr1F6OJSatkJF6srbE6RPTF1fbthkfV4/EXytuJsRd8hefkZ5bsayPf2o
         R2/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Z99G27Lzy67exZmkSSgaAeEp5wxfmyOARbAWmkyC0fM=;
        b=BdSZqkHy6f3/SCaKi9nyJ9r9E2FuRdCVVY8S7efFQja8tTmlqygOSsKkW1SpAzr4nN
         ttnDUPEr6eMQ6E3uVumXQ19SA2BaZ8PNjaNIGEYvHt5/RbGFViks9zK3WXaasIdlynlj
         yfhz/vku0V8JilvsnS1obKtpnUt4nBHuPn0zlF8xEKTDqSzTFsHX3+aQWg2ceFjMjIg5
         sC/D2NV+SuamIyAFQPWttph/lH2CnA7PFXfHIpn+HnM9i5WyBHmWlnGGPLc0X9XIRM5L
         44JvdSqW7Pxfq8Tt+FCZP2rNKxC2wMLz1LVNJrWZwiKzNnzRoiNn9PfW4UO63YgONjZl
         6hGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f44si10982730edb.68.2019.07.25.03.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 03:13:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DF2CBAEAC;
	Thu, 25 Jul 2019 10:13:29 +0000 (UTC)
Date: Thu, 25 Jul 2019 12:13:27 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 2/5] mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
Message-ID: <20190725101322.GA16385@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-3-osalvador@suse.de>
 <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
 <20190725092751.GA15964@linux>
 <71a30086-b093-48a4-389f-7e407898718f@redhat.com>
 <20190725094030.GA16069@linux>
 <6410dd7d-bc9c-1ca2-6cb7-d51b059be388@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6410dd7d-bc9c-1ca2-6cb7-d51b059be388@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 12:04:08PM +0200, David Hildenbrand wrote:
> As I said somewhere already (as far as I recall), one mode would be
> sufficient. If you want per memblock, add the memory in memblock
> granularity.
> 
> So having a MHP_MEMMAP_ON_MEMORY that allocates it in one chunk would be
> sufficient for the current use cases (DIMMs, Hyper-V).
> 
> MHP_MEMMAP_ON_MEMORY: Allocate the memmap for the added memory in one
> chunk from the beginning of the added memory. This piece of memory will
> be accessed and used even before the memory is onlined.

This is what I had in my early versions of the patchset, but I do remember
that Michal suggested to let the caller specify if it wants the memmaps
to be allocated per memblock, or per whole-range.

I still think it makes somse sense, you can just pass a large chunk
(spanning multiple memory-blocks) at once and yet specify to allocate
it per memory-blocks.

Of course, I also agree that having only one mode would ease things
(not that much as v3 does not suppose that difference wrt. range vs
memory-block).

-- 
Oscar Salvador
SUSE L3

