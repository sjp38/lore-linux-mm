Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2442C433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 07:17:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 523472089E
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 07:17:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 523472089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A18116B0005; Sat, 10 Aug 2019 03:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C87B6B0006; Sat, 10 Aug 2019 03:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88FC66B0007; Sat, 10 Aug 2019 03:17:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2626B0005
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 03:17:06 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k10so4919651wru.23
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 00:17:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UJZGNSSCyuxuFHSRwEDDxQWJByArmQB1KVZ4l84nfAI=;
        b=TIvY/6AZlHjEpKfkEPjz0+uEXduq8o7ZgFwLuCOXzJ9qhkp0Ep2iVCexfa59khxEz1
         4VXOwqieQJvuGSVVcU1t6MGnokOrcPa5SdulAChBXd6b4RG9zgASCXQGHKUPehiodK+r
         F/rN7PNcMiw33jZTZ56bol7h2n1VHdtGSP7D4J++yZEelDSv8AnDAC8FvaKOVvzu6rZg
         TRrVmkaY+kz+cPUa/2sZje3B2w91a8YvC+WW9X0ntux5/lEztBhxceq+pLQY+N3R7vm/
         m7a7JLZ/MsMwi9sVVQWYkJsW9wELYCDGw+riSM9TQCPOmUDBlwWONySJ7g8NUh0Gema7
         cosw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXAydEg8XZ7brwoGWA4Xfvnqa3e/uLhkgA6S77DmaEzC2mP21+7
	bR2DE3FqcYThYBYhk+FIqLuu1rLx49QwoaR8oUjfxRTtVC7/Pn2Xr/W5O3Q7wPZZe3L5L2TNKTg
	pWwFtKOlZxTvCCxDrPph6b5ad45eYwz1BOUcdgQlZ6epj9b1RUWuzVK4yne/Dd6AfBQ==
X-Received: by 2002:a1c:f913:: with SMTP id x19mr15208258wmh.139.1565421425794;
        Sat, 10 Aug 2019 00:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqqarX6gag+JGjMX3JQi6eOM0GYCMNNGhpEMaP0TnsP31COVYH1STmOAVGYYsaRb/2KUvh
X-Received: by 2002:a1c:f913:: with SMTP id x19mr15208190wmh.139.1565421424969;
        Sat, 10 Aug 2019 00:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565421424; cv=none;
        d=google.com; s=arc-20160816;
        b=uOynSK4kDz/Zoufc1J29g2Pc9kmxyfMa1FA5GU60xkSi1plksQwaQmdA3ujX2/lwJS
         aLMv20RDBFo2cka1iP46scbC8qFM3jL5ragbV7JEVGakDxs0Yxn6FDo2klDm0QoJYdcb
         XUnHGYpD2rJDiIyOYmoLbZM0KQx3sbQbJOrBZVfHOspob07gGU0CQg8o66xhi11KWpos
         5Lfsx1YDGT6LvNg1Uk1fE6d1uFNB+cvWlIJsIZI0KiIVg3WNoApeFbWeyQWxFGoJNOmx
         xS/TbqtKduxsKDvyNEcVVzK5XMSyDOJzD9xPGQtXZCXVvn8zT9Os3OFuTIO90sUCeQOX
         vnWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UJZGNSSCyuxuFHSRwEDDxQWJByArmQB1KVZ4l84nfAI=;
        b=Iiz3HRyG6n+9I6tKcLfoy/0AidupTnUzvYAeFbtUD+kh5P1ppY6UEJ2OlFhov2B26f
         2idD6VwlUa2o+8XZqpf/i/eznI8EmnsrO4eFyv1xesV9H5KGgDG6jGoOFIXmsM4PXLaz
         2UUU3KzmpZdVt95Z/Asn9iRgAUTXhK4e1bjXhaqcBszzEaiGhtcwaHwQREqi3LkpugOR
         H2Z7czCbfSjYOEMPNZsYZVrmqEOuwbd+Zp5KCjV2rd/vFEAjPr7V5sjeZ2ZmOGWp5/DK
         wt8xMST9Pxi93bQ/Lu/cBmU6Lil80tGbiRSGuyY5Bji1JoBHzlbpyQ9X3EwAIOeNVzk8
         Wn7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h14si5655741wml.52.2019.08.10.00.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Aug 2019 00:17:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1765068B02; Sat, 10 Aug 2019 09:17:02 +0200 (CEST)
Date: Sat, 10 Aug 2019 09:17:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anatoly Pugachev <matorola@gmail.com>
Cc: "Dmitry V. Levin" <ldv@altlinux.org>, Christoph Hellwig <hch@lst.de>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sparc kernel list <sparclinux@vger.kernel.org>, linux-mm@kvack.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
Message-ID: <20190810071701.GA23686@lst.de>
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-10-hch@lst.de> <20190717215956.GA30369@altlinux.org> <CADxRZqy61-JOYSv3xtdeW_wTDqKovqDg2G+a-=LH3w=mrf2zUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADxRZqy61-JOYSv3xtdeW_wTDqKovqDg2G+a-=LH3w=mrf2zUQ@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There isn't really a way to use an arch-specific get_user_pages_fast
in mainline, you'd need to revert the whole series.  As a relatively
quick workaround you can just remove the

        select HAVE_FAST_GUP if SPARC64

line from arch/sparc/Kconfig

