Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C868C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 04:38:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDA4921773
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 04:38:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDA4921773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66CE58E0003; Tue, 19 Feb 2019 23:38:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61DCD8E0002; Tue, 19 Feb 2019 23:38:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50DB28E0003; Tue, 19 Feb 2019 23:38:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE9A68E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 23:38:39 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v1so1510150eds.7
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 20:38:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Cj0KznzWs5dqkkWAOilS7Mp4dDpFdC0jZuz+w76rPWY=;
        b=DCyE3ID0IOxctU8QzC981PhKJPLH6NMerft9UPe+gU35GLlnXpA4xar7oyrN0yI0ut
         ontAQ8zIV3XF28ZiXAsa8qUbW0qtYFLCHqYVGlP7NxRRpCRwJ6CcUCSrOengWxnOBq+z
         lojAHi+Kpz3l92gfRtumZPhIMZ+0aAD9eJSWiMk6zVmCcjqD58mGm6zwS2JrMGp9zjBC
         zwu/xCVoq/Qxbd3uQdjFn5ggIQF/lcrD+4jPmpvyoaMLX/UAuHWA/9T5Ruq63qDqrmCt
         KhRNjslQO1wZ4cW7aVjxW+bD0qUKDVxRe1gwq2mo++7aRTTRy8tWHm6PD73DqOMPPBCR
         D6Wg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZ4lqMonMYbLGW9/kt7n6R21mCOpvoqqNsFilfQg1Kh7emYD3K8
	aNYqZhrf4DH6BfD8egGPYSA9u3peZk5JwSJaiJiQTYWfHHBftVrFA8KcJthRBd9mIGB66vwwksa
	GqCv8YhhWtig6yFFVccI8YMh7VtvLNzUdsuDYeDtEMJJHX1Ra+jHtnpKGn0qtHXwh4A==
X-Received: by 2002:a17:906:3749:: with SMTP id e9mr23116989ejc.194.1550637519468;
        Tue, 19 Feb 2019 20:38:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZnLB0gVr+9KSQM7K0HVeC3m/01TrlXlB4UDa2Q1X7JhploZ6QfK2Jvke0fpyrYpbV9asD2
X-Received: by 2002:a17:906:3749:: with SMTP id e9mr23116962ejc.194.1550637518684;
        Tue, 19 Feb 2019 20:38:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550637518; cv=none;
        d=google.com; s=arc-20160816;
        b=WH7UGhWxUQ22BfUAkWg0BIs4gUHv5q1bLUBoCHaDNCgQzuq609P0/nomQH5fza2G/a
         wHNkbqyXajT2w3J6lq2ki8SNLEVzR1VtfeiFL2K4AnYYu0fWLGPuLR9CH/GWOe3LZY8f
         85gmuUyuFCEHbE4wU1aLOAZRbPtdpQX+sY5Lv2u8CrYHeYDYIo7QeyGWtchoH6i37OGA
         Q3uGyTFz+LnGXv3GeNg7Lhzz7qNXQdZQ31yIc+d5QW07dd0D+m6grrQLeiryzso9f9dV
         TbgzsLtAJptqdTAT/Kr24jmXK3vOUbt9vGOJoeslp7oGlIbgI1u8x+YQWBbJkLn44V0i
         0N+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Cj0KznzWs5dqkkWAOilS7Mp4dDpFdC0jZuz+w76rPWY=;
        b=AMeS1TLCBvVQ5ol8/Q6yCnAjcWTZu7uxlUP4fGlx8qoA9JiQbyEbyJlXUBqPMC2StE
         XWqIvXBIaB0DaYXNdVVzzpfdjb/6/CwgfgP2wqjEH+ElmDhonbvizwRbPICYEzoee4kE
         WNQ/bMRI0PZRtw3L9JSywyIPTFcguMIq+Jogf+Et2IhdGJOhMoIl+2jvA2HuaiNo8shb
         Meryc/mw2bygyeibNd5TkjCWQsiMVV38zVB4AO/gZAavlGZlgdYbis85ahzDyEt9Unxt
         21RDeb0UkjwhqzYPEYoJgKU38t+DXjRcn/NrGXfTjHbjPMb1K+zApdArEfvLCDY0eJxg
         QKuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u33si2002262edm.37.2019.02.19.20.38.38
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 20:38:38 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 35A33A78;
	Tue, 19 Feb 2019 20:38:37 -0800 (PST)
Received: from [10.162.40.115] (p8cg001049571a15.blr.arm.com [10.162.40.115])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 49C113F720;
	Tue, 19 Feb 2019 20:38:33 -0800 (PST)
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two
 lists of pages.
To: Matthew Wilcox <willy@infradead.org>
Cc: Zi Yan <ziy@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, John Hubbard
 <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>,
 Nitin Gupta <nigupta@nvidia.com>, David Nellans <dnellans@nvidia.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
 <20190217112943.GP12668@bombadil.infradead.org>
 <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
 <2630a452-8c53-f109-1748-36b98076c86e@suse.cz>
 <53690FCD-B0BA-4619-8DF1-B9D721EE1208@nvidia.com>
 <20190218175224.GT12668@bombadil.infradead.org>
 <C84D2490-B6C6-4C7C-870F-945E31719728@nvidia.com>
 <1ce6ae99-4865-df62-5f20-cb07ebb95327@arm.com>
 <20190219125619.GA12668@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <749d5674-9e85-1fe9-4a3b-1d6ad06948b4@arm.com>
Date: Wed, 20 Feb 2019 10:08:36 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190219125619.GA12668@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/19/2019 06:26 PM, Matthew Wilcox wrote:
> On Tue, Feb 19, 2019 at 01:12:07PM +0530, Anshuman Khandual wrote:
>> But the location of this temp page matters as well because you would like to
>> saturate the inter node interface. It needs to be either of the nodes where
>> the source or destination page belongs. Any other node would generate two
>> internode copy process which is not what you intend here I guess.
> That makes no sense.  It should be allocated on the local node of the CPU
> performing the copy.  If the CPU is in node A, the destination is in node B
> and the source is in node C, then you're doing 4k worth of reads from node C,
> 4k worth of reads from node B, 4k worth of writes to node C followed by
> 4k worth of writes to node B.  Eventually the 4k of dirty cachelines on
> node A will be written back from cache to the local memory (... or not,
> if that page gets reused for some other purpose first).
> 
> If you allocate the page on node B or node C, that's an extra 4k of writes
> to be sent across the inter-node link.

Thats right there will be an extra remote write. My assumption was that the CPU
performing the copy belongs to either node B or node C.

