Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EFA5C10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:51:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F4E3217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:51:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="GaW3shv7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F4E3217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EACA18E0004; Mon, 18 Feb 2019 12:51:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5C9C8E0002; Mon, 18 Feb 2019 12:51:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D25688E0004; Mon, 18 Feb 2019 12:51:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5D38E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:51:36 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id i129so11324145ywf.18
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:51:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=oAMN2SMukQAAwRMkk7Z9t+qJkQU7W0HY8HzcNJMrMEY=;
        b=Dcj9+uYlr0YbRz9UYw4R8rub7zpbJsVkbhU96UV8BZnKKheekWxSgl0iRjCz2HCyQz
         P8iBCLNMllfSpGqjf49jZegMdKH2m410X2b5fcvMFGeD5gQXNdYQWPglXTwycx3Auw+T
         OQSRjbp2XtvV51logCWtixNElFGZIFUx63ID8fwrNe5GAnZMAOUtCBcM/EcIj4xdhulZ
         p0sj/llWXJ+DZzA/C7l3lQKbMNrBRJJpH2F4XRnyJkjWwQqdhc7pLv8MsWZJW5+prVfx
         CS3DDsFabfi30bPtPDB4GlrC72mNKkTNdhx6/689nHkn3IspFiAYblF4qMO3InKRcAuY
         8KjQ==
X-Gm-Message-State: AHQUAuYySzvC0TF+fzPRQ5X2AT1QwGcyZrFmjjg8zAfojMb5uJIVCuum
	OfPbELzjeKJjUqAQWFZhcuv5umx2JghzBTQijpsFyhu59XaTnO7Kj/CxLK47C65ASH7EdRFmY5U
	iHXWw8aF0faKYI+BmzyppSYKo+yoyxg39J6y/51wg6U06gMvevksCowkZ9w/e4ZdjZQ==
X-Received: by 2002:a25:3489:: with SMTP id b131mr5469053yba.266.1550512296331;
        Mon, 18 Feb 2019 09:51:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4fXEPsfjaSd45fciIHJEIJeNZznD4bdHDhECAiIJbj+Q+JW2qFE5ypucXRpAXanIg43ij
X-Received: by 2002:a25:3489:: with SMTP id b131mr5469031yba.266.1550512295826;
        Mon, 18 Feb 2019 09:51:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550512295; cv=none;
        d=google.com; s=arc-20160816;
        b=ZlfyjG2vTGRDkaCxa2wNrDzY7sv26JVR2ina4/TUsUjpIzzjU0WDagXaOFNm+d0CfT
         W5c+xeUhSNjXIfAmNOXlRbXVBXgfRBCMvWK1Gx/AoYIokeXUYLcCdeG8AqKA+tPHb3uf
         7YRe084oBNO9tvADfUMavt1Q7rC91nnf6krM26/coMDWV3eIhPUvo9l15Em58CWicLg/
         l+ffCQK34pfWrv46toLXtN1O37nkVphkVrNXfnYgBIOWg4NkYCxsxhDrcwerqG2hSKHB
         2HDLmUT8+YmnoVDv4jc3clK3cggVfIIVWq3hlHsZbw78USvZiGvkyrSvpzBoT280WfoC
         LuHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=oAMN2SMukQAAwRMkk7Z9t+qJkQU7W0HY8HzcNJMrMEY=;
        b=mOEGbCR8745RPJvTnZzbmMwFdCmf0jR1eWpJvObKqMgcKgyM+iDppL3kJnH0VFSKKi
         IEDwm2JD2tS1heUipE6ewlm7hoUa1ZznF6bwHTGuQ6WA+lFqW4g8Blb9HsQzLXT3IVzP
         tIl+TbQRnFHDF8m3bY37c2+b2XwAlGYbGcf1WT6CEK7wmJFX4+t2JEKKBU4bzd5e9p+A
         61lOvSFDSH9BSvZLca1udb+rWnmRn10acQHpmjM22dyMcQAjvBgNCnP+ShulpgUPPn3l
         bB5dl7YQw/TldF2033CtLFGHw4mjbFENyQOhC/+iqdS2rNc8apvup9soupjCBE7TG2D1
         +6Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=GaW3shv7;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 81si2238900ybe.390.2019.02.18.09.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 09:51:35 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=GaW3shv7;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6af0ad0000>; Mon, 18 Feb 2019 09:51:41 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 18 Feb 2019 09:51:34 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 18 Feb 2019 09:51:34 -0800
Received: from [192.168.45.1] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 18 Feb
 2019 17:51:34 +0000
From: Zi Yan <ziy@nvidia.com>
To: Vlastimil Babka <vbabka@suse.cz>
CC: Matthew Wilcox <willy@infradead.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two
 lists of pages.
Date: Mon, 18 Feb 2019 09:51:33 -0800
X-Mailer: MailMate (1.12.4r5594)
Message-ID: <53690FCD-B0BA-4619-8DF1-B9D721EE1208@nvidia.com>
In-Reply-To: <2630a452-8c53-f109-1748-36b98076c86e@suse.cz>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
 <20190217112943.GP12668@bombadil.infradead.org>
 <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
 <2630a452-8c53-f109-1748-36b98076c86e@suse.cz>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; format=flowed
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550512301; bh=oAMN2SMukQAAwRMkk7Z9t+qJkQU7W0HY8HzcNJMrMEY=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=GaW3shv7rI8TEPkLO/Twt/a8gREXMYf56YGKx1eJyIRyFLKzbYW4CobkfS/3jqagM
	 35C5RjV32CtSxtAHqo5zPJWeNc6Ic1fxJNIIgbcH/pmU6q8oS8+LbpPWnAZH4aQJNF
	 GHYzJ6T2TLTVjbME5dxbDRtsJOREdb1b7wQkerwm63KXkmB7sHCR0QazzCzmRn4UpG
	 TXX8EB3hNynxF2IdzXsARkIBe19W0C8KpbJ0FwmbzMHdafVZ9gVskvx5FGpqa1VCWT
	 QI7M5+fKUTxvOuSBUNbxaUXsfCE99M05z20iCkTEDRq6yVlsr9f4c1y7DkJYfxP0b+
	 NNg1Is4W88Pcw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18 Feb 2019, at 9:42, Vlastimil Babka wrote:

> On 2/18/19 6:31 PM, Zi Yan wrote:
>> The purpose of proposing exchange_pages() is to avoid allocating any 
>> new
>> page,
>> so that we would not trigger any potential page reclaim or memory
>> compaction.
>> Allocating a temporary page defeats the purpose.
>
> Compaction can only happen for order > 0 temporary pages. Even if you 
> used
> single order = 0 page to gradually exchange e.g. a THP, it should be 
> better than
> u64. Allocating order = 0 should be a non-issue. If it's an issue, 
> then the
> system is in a bad state and physically contiguous layout is a 
> secondary concern.

You are right if we only need to allocate one order-0 page. But this 
also means
we can only exchange two pages at a time. We need to add a lock to make 
sure
the temporary page is used exclusively or we need to keep allocating 
temporary pages
when multiple exchange_pages() are happening at the same time.

--
Best Regards,
Yan Zi

