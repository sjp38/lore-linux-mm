Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD6FCC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84B0D20679
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:34:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84B0D20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 203F98E0035; Thu,  1 Aug 2019 12:34:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18D988E0001; Thu,  1 Aug 2019 12:34:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07CDC8E0035; Thu,  1 Aug 2019 12:34:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4AAA8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:34:58 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id s18so35725179wru.16
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:34:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wd/uvyVistMMZqkIkGgugsxYNFCDee9kW29QUrH3MiY=;
        b=EH6el7HW0EFsdtpjJaFmwISu2J6xMWuXenZsapAp4VPilVPnKe4GxOoBN40qlk+8K/
         kWYZtMVEGURMRCw1EoAMLKiqhUHDhDqvZoa+p5uqcCFWniVGeaOgk0p2Lb9kKw2Ej1N0
         +IbGJHBWmqR0XwRENh1i2KZvff8Vtm+rLCxNc6b6Xnvem02lQojUnWmIgKmaK3aO3IpF
         pvFiHzImk5JiQ7Ta3vcNIV53zWgxmNaqfdi6zotFxmrxuaul41A8i45c4BI8ZOg1kOfc
         7H2Wquf2NZ1jYhSNrkaLm7A4E9ujQ/K5CKMJI4iZtfj6CGIsFgitjnakZIFB+v6fG/82
         11KQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWrGWs9/FnCfSrB0khnNpaCpWsyzl/HjkbnAr+VpZuO4/TpGD4R
	BDO9twNlxhRCbVPgrnhqDijMRGl2eYm/2HrYRUDBYGq76gwckGvpABQy5zvSHEaOLJvxpfWSzoQ
	8KHYf6r/GKAY+wpB87xUh8r+3xOW7L8z8F9yhrvsQaX7MrhJy8SlGAtif2+BLxvUuwg==
X-Received: by 2002:a1c:3c04:: with SMTP id j4mr110109395wma.37.1564677298385;
        Thu, 01 Aug 2019 09:34:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkbmb2hJMSa39YTx8Vpf7mEMd7esSxLBz3S1Onb+T77zG08Sgyvo/dmkIGqZYlXJ3yaOEm
X-Received: by 2002:a1c:3c04:: with SMTP id j4mr110109351wma.37.1564677297313;
        Thu, 01 Aug 2019 09:34:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564677297; cv=none;
        d=google.com; s=arc-20160816;
        b=jMNqsefv5SESi1q9TydRnSnVvHTEU5+gVEY0OkLG4+yiPpXRKe2nDxP/4n7WephhJr
         tCs0LZkNipLckHwt0ogvkjSD/fLyn2e3UV7hMOHMzOHUmuINQH0BF3KGDqTg1QcfOGXM
         7kmJ0jZ7jLocqQIGwPolBXDm1MY6NDIh5Mcqo6IOHWcwY/4j8AJEudMxR5pSoNhFQRtB
         O2Ve6r4VaCpFK9O6xmp9I+H4cbOjRFbLo6lsJY7Q10pg7e8avMIDMFKn0PLWq2SPzzJQ
         H6TV5BkuntNHNLUmsNXpeVXcelNkDIoxnrPr7f23HLtfMG3DZ09b2JGlMb4wGJDzXQtl
         ZHBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wd/uvyVistMMZqkIkGgugsxYNFCDee9kW29QUrH3MiY=;
        b=cvuHBBvJWuQPIgBF2ZE/VqS3KMts5shAB0tix8QR9qJ5MS2xuIbTTiJmBQHfJhRcCi
         ykMb+MIsnTZw2giBB32aNBxKi9oogG5PZwmittuBwoctCb+a077Sgifw/E3ECn8S6mlN
         MGB5BH1cyTZBXa37Otsi4SEBuUw6TEt6b8qJvV9iqnPdl/LQVBq/fsvp6Syhn3e1iBYr
         1xOiZRBGXBt4MTH2P8uf0zj5iaA8YDuRoHV6WKQan4523UsyiRABDKW9DHkGWebu+Uh5
         Gof80bzq205UEpKeM9Ph/nFAcYARh7Dzi77+Ue3RkCiBWAEsg70MgaZXwfEEfAhF0cHS
         uvwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 6si52765406wmf.124.2019.08.01.09.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 09:34:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 66C4868AFE; Thu,  1 Aug 2019 18:34:53 +0200 (CEST)
Date: Thu, 1 Aug 2019 18:34:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
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
Message-ID: <20190801163453.GA26588@lst.de>
References: <20190730205705.9018-1-jhubbard@nvidia.com> <20190730205705.9018-2-jhubbard@nvidia.com> <20190801060755.GA14893@lst.de> <20190801141906.GC23899@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801141906.GC23899@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 11:19:06AM -0300, Jason Gunthorpe wrote:
> Sadly usnic does not use the core rdma umem abstraction but open codes
> an old version of it.
> 
> In this version each sge in the sgl is exactly one page. See
> usnic_uiom_get_pages - so I think this loop is not a bug?

Actually, yes - I think we are fine given that we pass in the number
of elements.  Thus merging by iommus won't affect the list.

