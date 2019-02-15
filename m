Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73303C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:08:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31ADE204FD
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:08:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="N6vgbDuA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31ADE204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7BD88E0002; Fri, 15 Feb 2019 13:08:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2BE68E0001; Fri, 15 Feb 2019 13:08:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1BC18E0002; Fri, 15 Feb 2019 13:08:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 717898E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:08:57 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i3so8084906pfj.4
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:08:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ekIKuh6zBnupKG9gxO673zuIE5kCUp3UX8vSRNljvIk=;
        b=eUvK0ZoZ3KiXkWPjRuslTobNHs69Bknnjm3lDEwGAOlP2ajRy27FpUoqrDvVFipE2p
         op1EX/lXBF8FHxNiPUQMXWfcdZ6c4prjaD0a60DUq5XheLgrvcwLiRppGai60JGIDXZP
         kLiK2XBSoangABKSpZv9h9rQUiJWqAwje0PQRkIxkQP7n8ADveilzOudFrgFrZeGIWO3
         VGQEEPQ0PI6idlbbteOJVQ5KQePNk/ie6knfquILcE3rX7V5mF1jbvPJtO0Q0920c5D8
         62zbXL/KDT4pfS7ba60Z8LdNmbHrPRy5YIJ9YjAGAWxKVINnNTCcb19yOrZWP1SHWBdi
         GyKw==
X-Gm-Message-State: AHQUAuZULmskPsnYW6Pu9f9EYjh712vKMrtJu85D/cSI1uKewsq/LUbx
	+lsXnsg5oih5J/Kw4DrVPThfmlZqDlz5vTXag1kG45Iz7AnLc3x9tMysmoBP9C+YUBh4MRwysUc
	u2s031AI+k4W6+M16ve94qz3Wt0ZAor1qlcEa8TDfMyoFLkvE+UVUsyPza9xTZLEJGw==
X-Received: by 2002:a17:902:b904:: with SMTP id bf4mr11281696plb.171.1550254136970;
        Fri, 15 Feb 2019 10:08:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbXE8PXKOnZQUUae5nu4hXQX6U6DOX7n/qhWe2Ax+pgQ0KTfNhsBnEjIKEqnuPbog1BUsE5
X-Received: by 2002:a17:902:b904:: with SMTP id bf4mr11281611plb.171.1550254135965;
        Fri, 15 Feb 2019 10:08:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254135; cv=none;
        d=google.com; s=arc-20160816;
        b=i4qL3i8TkbFz5RSdfxlfOuCbsrbdcXn3iuNK3MbyjpGyMLfawe8u8eq/4uqI7E88LJ
         iW6UlGYPj1RUHdhx/5Qnaqhk5ykIPNFk/J7RIwg+o8leAQ21PIJBOSHpzcg3ROvFtTJ6
         REYxCctWbtMu92uDblsS0uXKOmskO3GdmL8kBCYCjn5Yt/VBr+kseB4RRH6N9SC6aZEu
         dRSELEBvoy4A7o/VaV4VUpfdayJkZ29a4b6XGrbKY99fnTpFsvRrRcs2TZpJy1/1dyX7
         LFsonNmZ1RfbcPI7kjEvgaibkNfkOXFu0mzWy0NkJX7iB2GZxWoVasTPx5dZ+am8RsaS
         x27A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ekIKuh6zBnupKG9gxO673zuIE5kCUp3UX8vSRNljvIk=;
        b=q9ni/3AkHx3I66ub64VDohs5Vaoq4w8I740OHlOdnT+QoDaSezkE9hVsEIO1e+5N2J
         UwKncxGg1MhaJtVIusAdGMA1k7Sk44nN8w8serPByBbsgJDm/xzbEOukQTCzzS6LJfld
         DSCf/mzJplzLppabGTiNeUDITRwYnO+n5hgg7T56YbKNtprBa14YVxPadp0SIEo0HCtn
         DmhG7nCspnrRb17hF2vfZY+3L/VpJ7bfKfev013J875iyrKm+++8JFqylv5SlLSFUM7p
         KqSzqJhCNdGkEOMkg4rtP0c8T655qTIporJ05cjzjNiH015ldn7w/gZB8H7+CGRxhGDJ
         yx6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=N6vgbDuA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c142si6153531pfb.33.2019.02.15.10.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:08:55 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=N6vgbDuA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ekIKuh6zBnupKG9gxO673zuIE5kCUp3UX8vSRNljvIk=; b=N6vgbDuAO0pFZp1PJU1ZeiFyA
	ytwPOqX5TusjyRZIce5OHcQYYs3JVVuTD5LuzVjB4CxjutjoKS4NZs9QFgUcKdXLB7gtJ1URorkMb
	TNstdGaGILxTXQmo0Qr0PM6yGl/H/UEiXQxcDH+CVG23ZcxIbzqjiNePIi44h8UtgBQ188zYyyTSV
	eFkDmiks78XQrfwzlTAk8egXMa9LlLeD9OzBkE5gSLkbtTTuPKq5G4cuAiWId9oCv28UJWxRVMkFQ
	C+2kwPtXa2mhF1XtTTcUxzUY1N0PthxEuqk6mq99jR2F3ASJNSYoge3Y5zgoFsHyC+XCkvgPfRZEr
	and9h+huQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guhuu-0003J4-NB; Fri, 15 Feb 2019 18:08:52 +0000
Date: Fri, 15 Feb 2019 10:08:52 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dave Chinner <david@fromorbit.com>, Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190215180852.GJ12668@bombadil.infradead.org>
References: <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190214202622.GB3420@redhat.com>
 <20190214205049.GC12668@bombadil.infradead.org>
 <20190214213922.GD3420@redhat.com>
 <20190215011921.GS20493@dastard>
 <01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@email.amazonses.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 03:42:02PM +0000, Christopher Lameter wrote:
> On Fri, 15 Feb 2019, Dave Chinner wrote:
> 
> > Which tells us filesystem people that the applications are doing
> > something that _will_ cause data corruption and hence not to spend
> > any time triaging data corruption reports because it's not a
> > filesystem bug that caused it.
> >
> > See open(2):
> >
> > 	Applications should avoid mixing O_DIRECT and normal I/O to
> > 	the same file, and especially to overlapping byte regions in
> > 	the same file.  Even when the filesystem correctly handles
> > 	the coherency issues in this situation, overall I/O
> > 	throughput is likely to be slower than using either mode
> > 	alone.  Likewise, applications should avoid mixing mmap(2)
> > 	of files with direct I/O to the same files.
> 
> Since RDMA is something similar: Can we say that a file that is used for
> RDMA should not use the page cache?

That makes no sense.  The page cache is the standard synchronisation point
for filesystems and processes.  The only problems come in for the things
which bypass the page cache like O_DIRECT and DAX.

