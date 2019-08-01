Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDA3DC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:08:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EDAE206A3
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:08:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EDAE206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF40B8E0003; Thu,  1 Aug 2019 02:08:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA3D78E0001; Thu,  1 Aug 2019 02:08:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A92578E0003; Thu,  1 Aug 2019 02:08:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5848E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:08:00 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a5so27154121wrt.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:08:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VQcYPtHxzMzUXVDsuQUJCCEVEdVeXdGSm3Qi6JZs/dA=;
        b=QD2O5FjywMjk1YTzxfWKfzS1T+xZypiQJK5mZuETDaSEzS02Pi7Ej+d7DNx1dVvsh2
         M1mgWYkGtYPC4776suhMdz82AjpQx6Gfo4L9+SFJLGiaMsjvoke+283PrtJVZ3ypxMtR
         keuqXv7D6EWucD8dHcC9oPLLlyEbWvHYSkjRh4u+EW//cpuXy7bFlCjJiqt14NxyO7js
         aVker27XSX9NsxmyumwDzl+ZHO6lG7+mRd4J6gNRnqUMoZk4HXnj3cHz1N/LrxCQDHzu
         /tW/97PRQw7EEitONkPT4oenhK+zGZFlzjk03byb2uWn33Vh9NlBusOSaMXCruU7n2L8
         Xy9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUGMi4/bRneZS/qkDdZfS8jwtgRnrJLLMplCKxnotfdcv1prqnw
	PFOMEETfeIjLxeCDd3tQu6R1coKbt2JHemxACaFj3+K5ECeeMGz3/ij1DbKDHPIp8VGvPHL0HMB
	eakG4dNv+JsyREojqDQ45OfZdrD0SLV5f2moOr96PYVfG8tV3o/y5o/GFrutscj11mA==
X-Received: by 2002:a1c:c78d:: with SMTP id x135mr106946694wmf.82.1564639679857;
        Wed, 31 Jul 2019 23:07:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4de15b/0NaDt9ZyE4bkskzjZ3WkGTls9jC11IVBOxrPMpVBOUc74N1l6BVDPRt3qVS6+e
X-Received: by 2002:a1c:c78d:: with SMTP id x135mr106946642wmf.82.1564639679087;
        Wed, 31 Jul 2019 23:07:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564639679; cv=none;
        d=google.com; s=arc-20160816;
        b=WHvGjUoUjugJbOFFGPgPIVS8MNF+2aPajhl/RQNUwZ6xDlR6/hVf33b8z7FIqsFWou
         FhhBYp5tlMhELa+wzKsqai4x/dnw3ohpBNhV881Z9SRyVxyc5YUFbAlmc7AetlUKgz4g
         k4KRrJShqGuoq/sBiHceNC/Mmax0tMHBlHHLI8g8wHRj5dyMi2/ZrD4e0ERmK6DSXUqb
         ZjolLox/FYNLwFXSZeH2L+yYnqVy1AFBLvxNfib5IUFOCjrNFn2mu8hei8Tyvmstl9bq
         8f4zhFzGRQVPXkvy+nUD5+peugBltRx4o64WwTnxvqPqqioUnJ4KD4RVH1HITKGkR7Pi
         gwKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VQcYPtHxzMzUXVDsuQUJCCEVEdVeXdGSm3Qi6JZs/dA=;
        b=pbcRKNsFI7tQAWC10VA1BZ2XerEpqNc637J1HQi3PgzKA25a0KDnkcPyP5XIB3pATP
         /a+jheSUwiUj4+OWbi0WoJf+UGcY3uJJOldHNzYVluIw7XjLk1k4BAchxDu7oqs4PcDE
         JclY6iPKCeYMPNGY7FE/wT6qWf2+mLokHmzKssZ8yleUfDFjTrHkdYuDq+okUm7CHnKi
         wPwRQxqAKJ/64mhQiKcGVXLP416OTk8Yp37lUJZ9w7os0MAeAHnW4bBA2tgQvsERl1th
         ZKj1itzyI+h0d1jCmBhLBPchLy59jynBuk5oySkDhCxpyeVmMSKUWMUs0P45V6CfxVkb
         GraQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n7si33844300wrj.323.2019.07.31.23.07.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 23:07:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9C9C468B05; Thu,  1 Aug 2019 08:07:55 +0200 (CEST)
Date: Thu, 1 Aug 2019 08:07:55 +0200
From: Christoph Hellwig <hch@lst.de>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Dave Chinner <david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>, Jerome Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v4 1/3] mm/gup: add make_dirty arg to
 put_user_pages_dirty_lock()
Message-ID: <20190801060755.GA14893@lst.de>
References: <20190730205705.9018-1-jhubbard@nvidia.com> <20190730205705.9018-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730205705.9018-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 01:57:03PM -0700, john.hubbard@gmail.com wrote:
> @@ -40,10 +40,7 @@
>  static void __qib_release_user_pages(struct page **p, size_t num_pages,
>  				     int dirty)
>  {
> -	if (dirty)
> -		put_user_pages_dirty_lock(p, num_pages);
> -	else
> -		put_user_pages(p, num_pages);
> +	put_user_pages_dirty_lock(p, num_pages, dirty);
>  }

__qib_release_user_pages should be removed now as a direct call to
put_user_pages_dirty_lock is a lot more clear.

> index 0b0237d41613..62e6ffa9ad78 100644
> --- a/drivers/infiniband/hw/usnic/usnic_uiom.c
> +++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
> @@ -75,10 +75,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
>  		for_each_sg(chunk->page_list, sg, chunk->nents, i) {
>  			page = sg_page(sg);
>  			pa = sg_phys(sg);
> -			if (dirty)
> -				put_user_pages_dirty_lock(&page, 1);
> -			else
> -				put_user_page(page);
> +			put_user_pages_dirty_lock(&page, 1, dirty);
>  			usnic_dbg("pa: %pa\n", &pa);

There is a pre-existing bug here, as this needs to use the sg_page
iterator.  Probably worth throwing in a fix into your series while you
are at it.

> @@ -63,15 +63,7 @@ struct siw_mem *siw_mem_id2obj(struct siw_device *sdev, int stag_index)
>  static void siw_free_plist(struct siw_page_chunk *chunk, int num_pages,
>  			   bool dirty)
>  {
> -	struct page **p = chunk->plist;
> -
> -	while (num_pages--) {
> -		if (!PageDirty(*p) && dirty)
> -			put_user_pages_dirty_lock(p, 1);
> -		else
> -			put_user_page(*p);
> -		p++;
> -	}
> +	put_user_pages_dirty_lock(chunk->plist, num_pages, dirty);

siw_free_plist should just go away now.

Otherwise this looks good to me.

