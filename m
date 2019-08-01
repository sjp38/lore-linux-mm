Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDB77C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:19:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D2EC20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:19:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="M+yZ5LoJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D2EC20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BF258E001B; Thu,  1 Aug 2019 10:19:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 070128E0001; Thu,  1 Aug 2019 10:19:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9F718E001B; Thu,  1 Aug 2019 10:19:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA32E8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 10:19:08 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 41so58927832qtm.4
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 07:19:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hMA7vlwUroWdb0REjDf2neAobLqIjEsoQepgHkXMGQc=;
        b=fpPIN1fncvrB1LXut9JiOelSVkhUjl7r8xd2CeqXh2q6ZF9/yWme79b+I6Zz4Au3qX
         W+jQLB+IQszgxtCPqDDvvf3DoQxljLujDr447BSF4/VHThL6gXgWRrSDsRjAXj0u6x+Y
         BBtRlo7F26n5Jibfjk1c0RB0XdMb9fYRM7WJv7NuuRNwYhP6QBScW5hMt0EYVoLC2wHK
         kBjia1fAbaiesQaG8jBCQZhfA/a7PMSrZ8yzXitLTGNvUQ2A3rl54SROGgfM1ZGkMtAQ
         O0jQNplbPvIOxVfL4YVp92J/XpJ97d2XDGTkbHHFrOTFpeL4wvUGqqMRT0KCCALHMKD7
         Y5fw==
X-Gm-Message-State: APjAAAW5IPBXQLVOGrkDlOvqpei1sy4i4gm7/XcAlXDCzDyouNIbhhIZ
	/Lgsg/RuQ5woJs6KqYu+/25MGTZusQElOshVnzlDXZVWjlnrQj5WggZXG1b63ZLfqUNbofEWWax
	OfcmIQK1uwySshzsRsb+YZVALDEVeUIUY+SzMoQZqTb5EBKvmd7gmB/QdFdgm14ETyA==
X-Received: by 2002:ac8:45d0:: with SMTP id e16mr19919471qto.337.1564669148600;
        Thu, 01 Aug 2019 07:19:08 -0700 (PDT)
X-Received: by 2002:ac8:45d0:: with SMTP id e16mr19919425qto.337.1564669148017;
        Thu, 01 Aug 2019 07:19:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564669148; cv=none;
        d=google.com; s=arc-20160816;
        b=j3+/h9I/UCtDzjjBKXDCIt7hIwI/g9q5XED1IikUdNFnJPe37weLJXcBybqWZ4JZ0r
         dGObN/NZ94BoTPKMhZ7svsVUfuY6AXmExyFGXdjkyrSg01DRj+QLVUhhuFfmemF9OiMZ
         OGUIiL3DtA26qrqXVk6BNYCbX1+Z+k5Wc6EwIbqqGQ7t6HLvPwnN60c/xGvXh5zeRTwv
         FHSrVQ9+1Q3yOtmNk0abEqd11sctpxQu+RhuDQn08zssCtlUnKRvss8qxWSeVJY4oQi7
         N6m7jkmCiqSJXo/DF3qHun/l2X4WMQEH+cg+6KCIKOs7hDCubNxZUyCgkDyomxeruSNT
         bt6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hMA7vlwUroWdb0REjDf2neAobLqIjEsoQepgHkXMGQc=;
        b=k+uzNotvtpccFQM/0mE4OVElHE4v9Ad326kP9QGxnLtf1jxL30JVV4FlOHzvT/dDGd
         X7EiKt4MVUbpLwjThBZM34W/r4plP+AKW7mVMvTAMwZ/L/TnsOgt8GE7rGWnn4mES38r
         DCsrvS6nIkGKhogmF0QaNwjQJ0bVEyTnZbq48iyHQFKz4IoDC/EcIapDDKZ3Qb6IoCwq
         upjjE88DAbKb0BxRyyieb0JqwK9LKkC9D5qt/iQ4CX/JDxXmr7EbsmeTZJEfFYQQ+Nns
         3xoKf+9Z5XsuyZh7s/3l4fqn6DqTWN9lqnvJyQksVIJylX44VyGYwju2XTjKfi1RN4Hj
         Q2kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=M+yZ5LoJ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor52901790qvs.7.2019.08.01.07.19.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 07:19:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=M+yZ5LoJ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hMA7vlwUroWdb0REjDf2neAobLqIjEsoQepgHkXMGQc=;
        b=M+yZ5LoJGbhm7g0i1sIHAJmyeoJlxlLUxNMBipkE5Gk2KmuVJyj40RCbT2OMJyeUYM
         zJHmHpLP79mwX+1GU1gaWmI+ZgMsrzh906sNv8d/eg/a5Xw25HKRKuFNgKcyKLM02Ww0
         rufqIlPpawx9cNcQ6Ahy2tSEtMjGQsDi0/1f8f63o7vcW+ionqvcAAZen0904J/Ypmil
         ZGhx4rO03KDS05ILM46VGBWJuCbsSKMR9WjJEMoOyUFc9cwx/Lc3OXwHZWF/4cg/Lo1f
         MMC8Huc/zfOSWQ3eMe0y7mSe9oVAGDhdbvvwgs3CG/GKyE01CIy0PPbv9CbdNkVNHI2q
         Ytxw==
X-Google-Smtp-Source: APXvYqwTQf1KGpY8PZ+10TO7pJmffd0/JJ0SGE6m65X5GOGwylr1cSmZUzuB803q9/jTvKSKgNYkxg==
X-Received: by 2002:a0c:aed0:: with SMTP id n16mr93783119qvd.101.1564669147681;
        Thu, 01 Aug 2019 07:19:07 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s127sm30805414qkd.107.2019.08.01.07.19.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Aug 2019 07:19:07 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1htBv8-00084t-Lf; Thu, 01 Aug 2019 11:19:06 -0300
Date: Thu, 1 Aug 2019 11:19:06 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Dave Chinner <david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>,
	Jerome Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v4 1/3] mm/gup: add make_dirty arg to
 put_user_pages_dirty_lock()
Message-ID: <20190801141906.GC23899@ziepe.ca>
References: <20190730205705.9018-1-jhubbard@nvidia.com>
 <20190730205705.9018-2-jhubbard@nvidia.com>
 <20190801060755.GA14893@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801060755.GA14893@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 08:07:55AM +0200, Christoph Hellwig wrote:
> On Tue, Jul 30, 2019 at 01:57:03PM -0700, john.hubbard@gmail.com wrote:
> > @@ -40,10 +40,7 @@
> >  static void __qib_release_user_pages(struct page **p, size_t num_pages,
> >  				     int dirty)
> >  {
> > -	if (dirty)
> > -		put_user_pages_dirty_lock(p, num_pages);
> > -	else
> > -		put_user_pages(p, num_pages);
> > +	put_user_pages_dirty_lock(p, num_pages, dirty);
> >  }
> 
> __qib_release_user_pages should be removed now as a direct call to
> put_user_pages_dirty_lock is a lot more clear.
> 
> > index 0b0237d41613..62e6ffa9ad78 100644
> > +++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
> > @@ -75,10 +75,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
> >  		for_each_sg(chunk->page_list, sg, chunk->nents, i) {
> >  			page = sg_page(sg);
> >  			pa = sg_phys(sg);
> > -			if (dirty)
> > -				put_user_pages_dirty_lock(&page, 1);
> > -			else
> > -				put_user_page(page);
> > +			put_user_pages_dirty_lock(&page, 1, dirty);
> >  			usnic_dbg("pa: %pa\n", &pa);
> 
> There is a pre-existing bug here, as this needs to use the sg_page
> iterator.  Probably worth throwing in a fix into your series while you
> are at it.

Sadly usnic does not use the core rdma umem abstraction but open codes
an old version of it.

In this version each sge in the sgl is exactly one page. See
usnic_uiom_get_pages - so I think this loop is not a bug?

Jason

