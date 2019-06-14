Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56023C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:21:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E72D208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:21:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E72D208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2A1B6B000A; Fri, 14 Jun 2019 02:21:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADA676B000D; Fri, 14 Jun 2019 02:21:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F1056B000E; Fri, 14 Jun 2019 02:21:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6899A6B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:21:39 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c6so174869wrp.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:21:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=a78IFQjTdQXsXyQjR1b73g4h2Qko6Y34o2l0kiUXONg=;
        b=K6D4YothgyfOkjQuWBEYOiHkyT6fOz7lU/FfE5xBmhIER0Gfz8Hkcmz5n4s3xV1SKe
         iu0nQsIU8mXzgvbJMUwb0s94Y51XCbb8ECFN/Wbc9JcBGBFIwCSk9lOF1cABqlx9IgnE
         QFx7wlNrVlDAG19btjD1bx9et5tymoc2JGNlBfusl5yHo9i75hqjuABHyXjztS7n4qap
         Tg3kkgOlk1B/CpRniATUdvxyKlYXNr9LOIKPBHOKF2JFUB5mFxJblYX7cZ1GNTwiKBd8
         R76QEwI/HtyYUuaNYKAl1muWlTVlHeLsbIXL1iONpih5VX4XxJECP4Uu4Q8i8axVVS3I
         OdAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWN5/oteZKiZIc3u1aZ4akT5pm7ubjLMuAyfLcDR4rGlZkj78+P
	nCEbrpuQ0L+CtTY/c/hXUU4K9jJCAcbr6HRsk9X5krRv5uHMify/3I7YGiPjkY47+/afwZC26lS
	8BmmEaghvNLRLmfim/BRh5fXhiPpVx/n0+lfcnE/9hC25l+Em7pfw3Sr6N1VXQmSYSg==
X-Received: by 2002:adf:df10:: with SMTP id y16mr4225477wrl.302.1560493298902;
        Thu, 13 Jun 2019 23:21:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFp/4bZd0t01ThxB7Zbh+tS5lm5cOnK3qQoLMYIucGgFR/dhW5aXzFLIAlLvVb7DRxm/zW
X-Received: by 2002:adf:df10:: with SMTP id y16mr4225443wrl.302.1560493298302;
        Thu, 13 Jun 2019 23:21:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560493298; cv=none;
        d=google.com; s=arc-20160816;
        b=b4TDpdYpH5hNrdg/3Wv/9Wx815GaabSNMjkFNdgiViKMfvBpbvvtATOpYqrtbueobw
         A5rQrHJ+GvoZ4m5RO+zj+ypNuCSRufT/a4keH0iEJx3ckLD4wh4GsGR9dSWCUnlWBZPI
         SgNXUsqZAAc3IOdwnstaSNIaaCCsUTLjnA9aiftYXoa0swYMSCPlATZGpO6gbrMmjchr
         DrSMesvbLZIOGEdW1ABWFW7QF926wUCnws1SCyMA3UexgXwxNTOviDHXeOtbRB+WUF6s
         h4H+ve4qWuk7kzsDCfPHPMIadUYc+twpd+U5UO2koQt4+gpbcj9I6IJXUiSArI5YA4ea
         WuHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=a78IFQjTdQXsXyQjR1b73g4h2Qko6Y34o2l0kiUXONg=;
        b=kIK3up4nAc9CmuonTwPHzYen14ASwSCYJrMeAKsjajxBqcaMFVtJQJSqizcRtkL/JO
         A2MRKhcHn/ypdvJt0Q3cp4xOh1LA3bBq4yz9AxmOUN4xK5PCfnsLI4UdPeIENsAHwc4v
         GZ2eu6fglb+MkDuIWYQcMH8WuHRniOyn9YWvw/R90Ck6HC4Asdao6QQ15lPta/kHePcL
         YWjap6zPauxH6P5rFfC0XBbWx0zPz8WMXtXJ+OKQditvMrWWWlKT7tQldJcJPsfaaLpZ
         9JL0JHqx13I78Hk1exJd7/rF+UG7hBQBQhojxPEmCoHudM89qjOC8YRmuOnZmBMWzpM6
         BgLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h6si1839000wrh.198.2019.06.13.23.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:21:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 105CE68B02; Fri, 14 Jun 2019 08:21:11 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:21:10 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/22] mm: don't clear ->mapping in hmm_devmem_free
Message-ID: <20190614062110.GF7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-5-hch@lst.de> <20190613190501.GQ22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613190501.GQ22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 07:05:07PM +0000, Jason Gunthorpe wrote:
> Hurm, is hmm following this comment from mm_types.h?
> 
>  * If you allocate the page using alloc_pages(), you can use some of the
>  * space in struct page for your own purposes.  The five words in the main
>  * union are available, except for bit 0 of the first word which must be
>  * kept clear.  Many users use this word to store a pointer to an object
>  * which is guaranteed to be aligned.  If you use the same storage as
>  * page->mapping, you must restore it to NULL before freeing the page.
> 
> Maybe the assumption was that a driver is using ->mapping ?

Maybe.  The union layou in struct page certainly doesn't help..

