Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6686C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:38:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 969DD22BEB
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:38:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 969DD22BEB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 346D08E002D; Thu, 25 Jul 2019 01:38:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F5888E001C; Thu, 25 Jul 2019 01:38:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E4D58E002D; Thu, 25 Jul 2019 01:38:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C53B18E001C
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:38:24 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id j10so20453552wre.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:38:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MnX4sjrjQ4hspDF2bRDdwlwL6iTF8xpxcMxVCrDD4pI=;
        b=jK8Gc4TYLvMF5jP7WC9O1DmxvohKTERJglmkapyS/AnR62EhbljjECm9qk2N6lKBEL
         yIOsJNI/ILwVmtpWHImnWvaG+S7LwJ2I3zYIlyN4UpbVzn41vtYsCmfV+Yk+KzfIYC7s
         IImRKm1WsN5wvKB/RZAw9md9K+B0wlFRMTv40tKf1YXJGdf3+quWdHhbaHC7tswdUonN
         Kktd+sDDPI6pd4PxlUPkB4w+K1IV40BWkghEjoSnAWE6fFaf8Lbke+yeAIQ2jZaWXk3N
         mtWibfTwkuxAEUs89vg34FDCrEP31Zj9d2IjwhxpVVrq9TIOg5kiyYmuouu5HCT8OCgJ
         +pSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUFZJLoIb/AsGDgTHP5xKes/9+gRhAzPbjkkDrx9K9twIXpa8Wa
	xrsgl8zQs38dPtrul6hybkGImPDhcUIvZRMB+KC0CtNpYmSknqVTJ+KY6M2jh0zM7iMw32d7esa
	InjbIbWCCEvJX0uR7cwuZm7HjJ7SoVkSUbtk9za3NFistbL/6bW2/lrSS/S3ggfdMCw==
X-Received: by 2002:a1c:988a:: with SMTP id a132mr75547273wme.165.1564033104320;
        Wed, 24 Jul 2019 22:38:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd1Ge6qb7Kb3X7FwUp2BEe9r/bFTcdP7vcTCx4jsnzEg1fjSxbpGv2Q8Qcmjv99PSn16yZ
X-Received: by 2002:a1c:988a:: with SMTP id a132mr75547243wme.165.1564033103553;
        Wed, 24 Jul 2019 22:38:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564033103; cv=none;
        d=google.com; s=arc-20160816;
        b=l8XAja1io2ewd1/Z0QlxZLPkda29ij6FFORcITsQjq7zPg6fRZvhPpaurRuL14n/Os
         Ey+OInZNBZw3Q0Gp1YgnbcCuLFOQLGtA/Xt9zWnIc/pr4+o5R0PPLgC+SEpOltMQWTu5
         jZLANgTM9kKOOh/TRbllCoWpoXqK7qeWuzJUiBeyIrHRC106cxhiQSwN95suftZ0Ufva
         jD49h64H0swI287q9x2XK1b4MYZzbHAn9VIOChkRtmLOmctcFgJ0XSShHGeJFUHZxkaS
         ydaX2jE76iBaHaI63k6pkDwt+t3mEo6x8QM3OSjkGQspR1ipzeROxJ5iHoRyI4SGvGRy
         Y57Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MnX4sjrjQ4hspDF2bRDdwlwL6iTF8xpxcMxVCrDD4pI=;
        b=Sgu0GcRQ8JSzSYyE+/mo+u1D3wrXLWUKxMvdxPV0FDOQHAx2JG58LMKYTCWOuvnQZN
         RIz1qr1BNuwT5/acPn2GRhb6LBbfYwiRg5GWASbv7hlrmRp/5pGtlITbSahQJKJY2ASj
         qHimEvLD0C+bQlKKZa5LlaWzV2ttgrEKpiTTrb6n/SLWvgnWxkrRXJSCXOWOgklfOdji
         zM+5VxmDtRkOJLmTSYATJRcZTDP3xzTz50/smimPemkWA9cIJ6B1s2NB3QmCeLvdjSdS
         U9p/wgCGDrfX16CkrXHffNcyYF6z3C74GgKDeYL0ucWC2RtyMWfRhTSWCrCqyuUQ1iv1
         I21w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m25si37727589wmi.43.2019.07.24.22.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 22:38:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id B331868B20; Thu, 25 Jul 2019 07:38:21 +0200 (CEST)
Date: Thu, 25 Jul 2019 07:38:21 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Pekka Enberg <penberg@kernel.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3 1/3] mm: document zone device struct page field usage
Message-ID: <20190725053821.GA24527@lst.de>
References: <20190724232700.23327-1-rcampbell@nvidia.com> <20190724232700.23327-2-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724232700.23327-2-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 04:26:58PM -0700, Ralph Campbell wrote:
> Struct page for ZONE_DEVICE private pages uses the page->mapping and
> and page->index fields while the source anonymous pages are migrated to
> device private memory. This is so rmap_walk() can find the page when
> migrating the ZONE_DEVICE private page back to system memory.
> ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
> page->index fields when files are mapped into a process address space.
> 
> Add comments to struct page and remove the unused "_zd_pad_1" field
> to make this more clear.

I still think we should also fix up the layout, and I haven't seen
a reply from Matthew justifying his curses for your patch that makes
the struct page layout actually match how it is used.

