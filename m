Return-Path: <SRS0=izd7=SX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36633C10F14
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 13:26:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCE522086A
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 13:26:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RgDwe3K3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCE522086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 249FE6B0003; Sun, 21 Apr 2019 09:26:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21FEE6B0006; Sun, 21 Apr 2019 09:26:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C3146B0007; Sun, 21 Apr 2019 09:26:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C3F866B0003
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 09:26:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i23so5890197pfa.0
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 06:26:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Rc67H1HDEjDy3HjQxasxWDB9M7vQy15mNKQuX9FUK1U=;
        b=GUUlDKeGMZswhSA73+hgVd/uW5mCH6jP3lH+nC6/1kvBzUhtDsu3IwyUjF4/r/09TT
         pVrqoWJXOcOE+w5zHby/NMXZt+wN6TLKhjNmM4ErvwpcPpAcH0vhdGNAAP65cAlcvcFB
         2g0qkzIdqPLTYtKrhzUbFOOUEuFK1EV7S50voOP+MKpbUB479eraQCksm637xUcqE3bZ
         AJ8mgkc8sN69SAXp/8PhU6QnfpN5O5zZk/YVZN2nfaRhwBx+y5CMTo7LHrNHBElPk6gE
         MTTtQ0UQmQsfWQTPresRipJ0K6Q4KrmZrW6zDHPp1B+xGyh8kgOK3ifnakivEjg/0Zi+
         M7pw==
X-Gm-Message-State: APjAAAUaRxk8x9K3kLI3Xt+/dqlGUKG38u8jlaclUOBJN4N/JOc1iMdg
	8m/fs4PpESSU+8cd3BoHGMZcLlXvmbvMRpcj/G7vJbmM9cxOK3HRtPFkvcT1dIZRejM3+yPMtwr
	M9RpoXw4X3jQSuWmhtJWcbpVDBGfnUJv9M3BNIkD8uHjUjmDK8PLP5QA3Z7AmUqxTMg==
X-Received: by 2002:a17:902:5c5:: with SMTP id f63mr14347538plf.327.1555853173190;
        Sun, 21 Apr 2019 06:26:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsIwAXLVJQUjBY6o/QczLfDA+AfqKNTTvQTcyU9TsLY12xyk8uACCDxViKbxnnTvaciv1g
X-Received: by 2002:a17:902:5c5:: with SMTP id f63mr14347481plf.327.1555853172270;
        Sun, 21 Apr 2019 06:26:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555853172; cv=none;
        d=google.com; s=arc-20160816;
        b=Ezlm0GkSHei83erL+dBWJg1HlqBNz0aGVmtusL/DO4DNANzSD4RPiInRIDWubbd+At
         UzdV1NW3S3cFELThIzT/y+noocKVBi8ltEDMO554fbFCi+2H4TdW7m1V/Hz7ue2LcD0k
         1njF3tYP6vNp5hB6bstylbEcIF0084YAVxJHfunCHmKJr9Zm4ctKBAqqpvmBYAcq2rr/
         +0sZXW7yrWsXZMzZu71OoDzy8PWixfqvBtPsis3K5msKYqvS8B1kMq+DYaMiI4DBSLnP
         1TTbIMPap/5iB7svZnmtHe4RNWkoQZxUlUcA641iIO68SVvHujiGkbcsG4oWyYSOgvs+
         3g+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Rc67H1HDEjDy3HjQxasxWDB9M7vQy15mNKQuX9FUK1U=;
        b=DFE1Mj3x+IovR2hz0E7qeMv3NnZI6UBmqXV+ZYK3FBfWK6JPCQWjuCvbSEL/ohu3wg
         J0RozjpYGZ69pN2GePi3CIEPpALWLmSyyKxtgHQ3dH4VMsyYSlxl9MWEaMUV5OYzmrtm
         XRbzh8dxykH2bPQy0qFXFMwI+HHEt0Jq2nZR6YaH9Sx/FZhhHAXbGGFvLleFNCli8sLv
         /lpDw7Oz5TD9IYHjlakXtrSEnv2p2KIDao70hYaXrzMJaCv8nIhYUgtDwgPHHPAzquhI
         LxhQUfVJU+ZEwDBjxvZvdM8CpWQ29Pfykqh1UUm+FAfXDd7TMT/0HvQeM/ht9ygEdU5y
         UY2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RgDwe3K3;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r20si10053172pgb.162.2019.04.21.06.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 21 Apr 2019 06:26:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RgDwe3K3;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Rc67H1HDEjDy3HjQxasxWDB9M7vQy15mNKQuX9FUK1U=; b=RgDwe3K3Ke2irRAMVA4Yuayg5
	BR+M5mJK9AmCzzfU5OcbUqI2BjZcqfev7ed/9vrArbV/YOAew5l297EsE2X6yaD3jvvUrPcrq1UbD
	0P5HUDSp+DlQo5Oh5ZIIHk3WkRqA0AovrVcIWw/wslFt9rRqrxSRYh+WCla/VeosnH+2t5io5FTUD
	g4XnitQYKo7V32SMmUH8yOQJiJA0+r/AIo51eUqqIKzTxr49vPVShhvM/R4RhlrvWT2HXJk+wob6O
	2dhMD6nMhbYh9Db8OAsuM1uuqEPVhzBTbbjV/tsTleBfK+Hv567D52zbX6MzjoUBaVHDk/9M3AtgV
	zaBGfz//w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hICTv-0003S4-86; Sun, 21 Apr 2019 13:26:07 +0000
Date: Sun, 21 Apr 2019 06:26:07 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
Message-ID: <20190421132606.GJ7751@bombadil.infradead.org>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190421063859.GA19926@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190421063859.GA19926@rapoport-lnx>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 21, 2019 at 09:38:59AM +0300, Mike Rapoport wrote:
> On Fri, Apr 19, 2019 at 07:05:21AM -0700, Matthew Wilcox wrote:
> > On Fri, Apr 19, 2019 at 10:43:35AM +0100, Mel Gorman wrote:
> > > DISCONTIG is essentially deprecated and even parisc plans to move to
> > > SPARSEMEM so there is no need to be fancy, this patch simply disables
> > > watermark boosting by default on DISCONTIGMEM.
> > 
> > I don't think parisc is the only arch which uses DISCONTIGMEM for !NUMA
> > scenarios.  Grepping the arch/ directories shows:
> > 
> > alpha (does support NUMA, but also non-NUMA DISCONTIGMEM)
> > arc (for supporting more than 1GB of memory)
> > ia64 (looks complicated ...)
> > m68k (for multiple chunks of memory)
> > mips (does support NUMA but also non-NUMA)
> > parisc (both NUMA and non-NUMA)
> 
> i386 NUMA as well

I clearly over-trimmed.  The original assumption that Mel had was that
DISCONTIGMEM => NUMA, and that's not true on the above six architectures.
It is true on i386 ;-)

