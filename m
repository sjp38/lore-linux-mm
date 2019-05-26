Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DBC4C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 11:30:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B85220815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 11:30:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="B9RbYvX+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B85220815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5BDF6B0003; Sun, 26 May 2019 07:30:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0C3F6B0005; Sun, 26 May 2019 07:30:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FC0F6B0007; Sun, 26 May 2019 07:30:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 675E96B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 07:30:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g11so10954693pfq.7
        for <linux-mm@kvack.org>; Sun, 26 May 2019 04:30:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Jw4RVjb44Rl/ijGMDvXlIocM4n+wpJ+gzkrVGf7lYHI=;
        b=Uz2tzH3G9R095XS5kiWR3Vpa2sywkGeAhi3AI7CY4sXo+Pw3m48o3jlDvYwzB7jlQm
         8kRUaJ5dY8FVy6MUBVhQozARe6GIMMy5W33nQBKWCQeYuJnHxAgV0p4FkEjDMTGDkKvS
         V0xKBlnIFUYM8ABqizDfVxDD9VE/UxJHGocXGhllUOOmzdssYQpKM5uyiGY0BejhBjO+
         nHkez0sKKkin3HV5dajZUab2oCbB1TJOE9I2+oO8AlGJCXLh/oWEbm/pskDpUh0PleOk
         SgAsLWAugFhCm2DCC+dbj88/8Oejq6w+CN85NkdwKNzJChIyGzad7Ii7PwCksTrwtO0r
         9QPw==
X-Gm-Message-State: APjAAAVjfNvJJllGyLfzgUmuAmz6BatIoRubJKjud+yxk5Lrdo1DDO7u
	Z/paKZ+w8OShnqLFXAZeZF/wUMgELAi9Qr+1nNb7YcSF9ncV8Gwp6hne3aD7Arj5HGwWRTweYop
	lQEojEXBIKjDZ0LGno04S5lKmFsHFq3NH36yScrLOrMuTRT7huLOQm8224D+6BNHkow==
X-Received: by 2002:a17:90b:145:: with SMTP id em5mr22932444pjb.35.1558870246985;
        Sun, 26 May 2019 04:30:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDDAhNH4rEaGo9dLhqSFze2SFc/9Ny9qxAO1cumgIA5ZxZCmXKbKug0tvQj55zmsTzj3+u
X-Received: by 2002:a17:90b:145:: with SMTP id em5mr22932368pjb.35.1558870246309;
        Sun, 26 May 2019 04:30:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558870246; cv=none;
        d=google.com; s=arc-20160816;
        b=PJoLBapYJfRe0ey6fq/OPAbZNpzjAhfEyDQ2MJyHgCWV4d2kjhOHtOFc1zrr9uFSUf
         vRCGzP610mCTf7hlcDuZTVTSiPzaCmbTIONpFkHePnsP+FHU6jkod5DNKkGObhoNIXwC
         A2KIspZO8RgPIzqP0GO5lX5Celto3cCtpGMht+fdPcUdH/5cynihf3m7OQ3jCGrLnKDd
         VC/Xn4Ecy8f0/MEIwk+4EKmV53hLjbqZ83Z8brGymwl1Z2oDOF36m/rCL3ycpKSVdH4Q
         HCo1kqCpeIwkdbu2kFGxBwTila4BzKr3DW+wOZLB7Q1vmM47R8lLkT/2AuT0XqqTCjxu
         FonQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Jw4RVjb44Rl/ijGMDvXlIocM4n+wpJ+gzkrVGf7lYHI=;
        b=HW8jaFhTKLWYElBwO0Zbp9s6LTTW1o8CKAMkZOJq/xvwjnWNaMNWBfAFJm5cO3g+F2
         6/A/Y0LHMBm559RGndnWfyQvMK7QlMuLiH8MRsj53nvZos6WxDgK+daegXydDL+976Hz
         qu3UsCBbzF/N7VlL7l+sVqGYuUMT8jcJbrzeAhT5KW/THWkbprtaJflBcFQGj6BQqxvJ
         vV2PxC7f6hHLVi5ML8p1ODhWpShnKWIguq2oBLAn9zCJhU2GSGvmW1VXZbOWt0uWphFz
         iQChTFCW/hcLCRa8w9eCkfrrlvoc5EZG2obWkq1Md6zSQd+4y/Sn18YA5GwxfisYI8qA
         TEKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=B9RbYvX+;
       spf=pass (google.com: best guess record for domain of batv+6f05114c0a2ee5174db7+5754+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+6f05114c0a2ee5174db7+5754+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 78si13650580pfb.102.2019.05.26.04.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 04:30:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+6f05114c0a2ee5174db7+5754+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=B9RbYvX+;
       spf=pass (google.com: best guess record for domain of batv+6f05114c0a2ee5174db7+5754+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+6f05114c0a2ee5174db7+5754+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Jw4RVjb44Rl/ijGMDvXlIocM4n+wpJ+gzkrVGf7lYHI=; b=B9RbYvX+BRYnxapubpxxADejO
	x66DQneKUCIAI1k9L+lDLC9ViSYCqJ/BatwnGD7a0pu9TzLVeiEfNw3idbXlvzBswV7SqthuEEAIx
	Gug0nME/T60pDeZvnIb91NaU4p+NdlQz/hKNrAbTYbomQJcntR3p8L4MN4ayKwjOUxNQaxF7BFlQ9
	3yFDRJB6uQ3Ezu7wghWk0H5Wy2JN8Bzl5/fQ0ht//A36yqfOwh+QxVBk3RI4xvRrwI1GRFmHg6Wb+
	Fpau3zojmKqj2m8LJPCcW77VqLs0A6eS3vSfp/oSN0Zs/asSp3mvW7Su4ojTsUCIYBh10TTMv8Ych
	fp2CzUbbw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUrMR-0002Dx-L2; Sun, 26 May 2019 11:30:43 +0000
Date: Sun, 26 May 2019 04:30:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>, linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2] infiniband/mm: convert put_page() to put_user_page*()
Message-ID: <20190526113043.GA3518@infradead.org>
References: <20190525014522.8042-1-jhubbard@nvidia.com>
 <20190525014522.8042-2-jhubbard@nvidia.com>
 <20190526110631.GD1075@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526110631.GD1075@bombadil.infradead.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 04:06:31AM -0700, Matthew Wilcox wrote:
> I thought we agreed at LSFMM that the future is a new get_user_bvec()
> / put_user_bvec().  This is largely going to touch the same places as
> step 2 in your list above.  Is it worth doing step 2?
> 
> One of the advantages of put_user_bvec() is that it would be quite easy
> to miss a conversion from put_page() to put_user_page(), but it'll be
> a type error to miss a conversion from put_page() to put_user_bvec().

FYI, I've got a prototype for get_user_pages_bvec.  I'll post a RFC
series in a few days.

