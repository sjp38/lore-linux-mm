Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26242C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 13:15:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D331620830
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 13:15:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="g1+ntTH2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D331620830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A21E6B0296; Wed, 10 Apr 2019 09:15:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 677976B0298; Wed, 10 Apr 2019 09:15:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58DD26B0299; Wed, 10 Apr 2019 09:15:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23DD06B0296
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 09:15:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g83so1743194pfd.3
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 06:15:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MEPaCQfo2hefz4J3PUM1A06gWxgInUirpFQlLPvFhfs=;
        b=DDals3mCKOkRb/dUOl/lV67IycOj9aBakFtzffTdS6Y4UJ+IPDuU4RQNeSohjHN+WN
         Jv6s9XTytaRGVhPF22cL9JW7xnPILXDUbeSYwmEwdzWBKgFMzqD50J9g6kFOhpgY1qsU
         PeuY2/p37Q7UAu4H24fyQopkyhiqzou8RpPFjyelHd2yCv90rmB3PGrioVaoodgQsaqL
         DPU7usS0zFZykDGG+AlBhAIIgjy8RH8qu2nAId1UpC2Ym0pVk/ny8G2tBkJ9UX73yWjW
         mxqkGvrQp0ffG3WkgDO9rtRuyyR9G0ETWPee3C9mFEt/7nmooOrd2zYgheT3pnRJ/THj
         kI7A==
X-Gm-Message-State: APjAAAUZDeeAGTCX9zj3360nKOdsncx1DlHW4PpSUUl3SX3j3CJg4pUW
	9FMn3JYJSsMcEGurv18HJAPfhRPl8Uyq+d+AKmyIZITzMqzjE+vk672LCC5bShSXB7UQNH2SN1P
	C2FK3GB4xnyPAOyCF8Fz1DN3oJRS6O49g6p4N9huq8aN+WkONF7RYl05Jpb07XpQT7A==
X-Received: by 2002:a17:902:9048:: with SMTP id w8mr44455642plz.195.1554902108576;
        Wed, 10 Apr 2019 06:15:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3vN2Gk9Tok+3ICAi/VV5cjdKJr/ReiWDVhE5l4bn09kgDV9Wt7efN366R7ooBu53zu7ZE
X-Received: by 2002:a17:902:9048:: with SMTP id w8mr44455564plz.195.1554902107692;
        Wed, 10 Apr 2019 06:15:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554902107; cv=none;
        d=google.com; s=arc-20160816;
        b=WUFKWRXbMCSjt7uLgFUj4abjOND6aj/YlijbQRhEl/oTk45JvPcKDi2QH/U0fTiEwU
         kc72iheoIOBtfzfZq7ZyH0MhlxBxXm4g52UGaLSxPZRjmoAI4uQjSfxqs/Hd3ywOBBwz
         NE0FabfpFi/06+sg9occCF0WdIGE8MPvtDOosL3cKsWdmZN2FAY9UM3/sSJNqx0LwgsG
         QylamOJWjnUaDoGtsaMS49qgosVadYN3OujIO5eVlrsNPOWdu0hf3u8D0uorFucki+z5
         gtmUzgwFCdpGn31dDFgu3YTbk0xsHQY2ymzKcLziJxjbDIPA2GOE23fFENl4/CxnQkcF
         MQfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MEPaCQfo2hefz4J3PUM1A06gWxgInUirpFQlLPvFhfs=;
        b=mkJiieYfzmW+lV9aB5+jBcLZWiLK2YlMzIdStrH8tGTpjhXgglxQzwybQwrq2t9Ate
         R/aZYSqnyealySpG0d1WK/gHdzTddhfwKYtnpIdIv0rgcDfqXE6uGK30NBMGYnj2/bN5
         IGrAAt9wihmt5384RA1iP+SVYXIWGpNbuPtYx7EMqVz+xrhqBXy+Bs08iYcKpqGKVbzW
         06UvKAa1NN1YxcNcKda7M2K/KQT+UQCjhC0aecsx4t2ektBiFxzmcgB3CPYLgBhF22qN
         xdkynYvcg1gWKigET0M+kWTKh/4FYSMm73rCxLw/tFKeC4RcValUHab1m3Ng7XCZ1nUf
         +MaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=g1+ntTH2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m16si29339348pls.150.2019.04.10.06.15.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 06:15:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=g1+ntTH2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MEPaCQfo2hefz4J3PUM1A06gWxgInUirpFQlLPvFhfs=; b=g1+ntTH2KjkaZY6X8gH2UpJ9H
	90kq4TsfAcfmfo8Q578x7gph3bIN0aFrH3DkHRz3yHtDgsn3yCt2r67Bd1qISmu584+ahidyQqbKU
	ICvIKeqVwwxGxh17ZV2C6/QLQB4+o5+1BalHbNqJezK4jy1KOKEjDiOj4ampYCoHD+uUe+1maXv3s
	H7cho5UOf/9oJAZnshxDSwxeR70o0hkUZW5aMAegPD309BLjudmq9L8OD0nV4jZ7E7Suh6Fn5aV9y
	9rYy3WEOkzvB9FnIUgwtXLeBraNkBI/b68XXVANLh5LnutlvhpR6skhrWakwT5ElpNu1GmW27l5Xf
	HAEr9iHKQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hED40-0006NA-Au; Wed, 10 Apr 2019 13:14:52 +0000
Date: Wed, 10 Apr 2019 06:14:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jared Hu <jared.hu@nxp.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"vbabka@suse.cz" <vbabka@suse.cz>,
	"iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
	"labbott@redhat.com" <labbott@redhat.com>,
	"huyue2@yulong.com" <huyue2@yulong.com>,
	"m.szyprowski@samsung.com" <m.szyprowski@samsung.com>,
	"rppt@linux.ibm.com" <rppt@linux.ibm.com>,
	"andreyknvl@google.com" <andreyknvl@google.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: question for cma alloc fail issue
Message-ID: <20190410131452.GA22763@bombadil.infradead.org>
References: <VE1PR04MB64290E25D6BAB7E702D08A54982E0@VE1PR04MB6429.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <VE1PR04MB64290E25D6BAB7E702D08A54982E0@VE1PR04MB6429.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 10:48:26AM +0000, Jared Hu wrote:
> 2. The pages that are free in cma->bitmap seem not free in Buddy system?
> PageBuddy() test can also return false even if the page is in the free list in cma bitmap

That's correct.  They've been allocated by the CMA allocator, and are no
longer available for allocation by the page allocator.

