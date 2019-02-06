Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4BEEC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:21:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99A63218B0
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:21:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Z+Z+SjPc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99A63218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C4568E0108; Wed,  6 Feb 2019 18:21:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3725A8E0007; Wed,  6 Feb 2019 18:21:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 262AF8E0108; Wed,  6 Feb 2019 18:21:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAF1C8E0007
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:21:33 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id j32so3405001pgm.5
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:21:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SerMT47P7Y4EGL4Yc5IRC0eutvUHMCX849kOCq3GxrU=;
        b=TWS3bhgZfbkYmAMyTQx6+il+tSFFsmtvpmdVkYgZBQtO7U5EAbSaOPizroCGxEopQy
         LNVH3LpcGXzddTUEDafYASBufofafUxSUYf4yLMUpuz1z0T0zp2o1wYYBr+iZfn68/+H
         q3lAByrMamhZiTMfwo/b9WW7Ot2fFmk2wmwabNDxSevckBt6cz6q5KR2VsRZkxgotQhw
         dfiftjynB5Bz7kZA58J2j0jB28gBs9g80gkfNnQqysRUF5OOe4uVyNYipLjODg4cQ/2e
         gn+rWz8zF7h7sIQsHVh5akaqaCUgetWAds1oM59pcKtVp0eM1mIQXscB0uUr+oHAERz4
         aepQ==
X-Gm-Message-State: AHQUAuaRrNe4qV9BA822rcuDgEYleoxXgdfYyAdVawlv+Qqc7bd+hEIi
	xq/0OvFe4vF4DpASaM4t4Uc2CY1YNiAhIzaCdsCFgdq0q7PnHQQqAKySXf8UmIBRaqzBEVmiDBJ
	0MnFlKcXfmW1UiHwpsKBYLwHlEcFlMUuHFfdau5M6im2yeqREMO0++LBKdSVidNLvo37aTCpDnY
	7we66FqyqIKuXyKWx70ElJXuA0Sz72Lwkk14jKYDt2J0Jn5j4yFvbnBxSSvFt8G7HvFA4lDnDJ+
	fFIVYRerBqBPGZh1p8uskhQUQ0zGsSl345tNbYJSwZ+ypSiUKh2jcb6t0sP03auqd3ksvoKeX0M
	8j/CRM2c2tt6Fpxwk63VkUpjT0qqWqtfIn9WfMW+LwZmM5LAo5OY6R9FbmZJh+TypWJOYo4miKs
	z
X-Received: by 2002:a65:63d3:: with SMTP id n19mr12143530pgv.179.1549495293528;
        Wed, 06 Feb 2019 15:21:33 -0800 (PST)
X-Received: by 2002:a65:63d3:: with SMTP id n19mr12143482pgv.179.1549495292759;
        Wed, 06 Feb 2019 15:21:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549495292; cv=none;
        d=google.com; s=arc-20160816;
        b=Ocq14w1cuv7K05YZwv2DVuU58YW2hc2sBu2efOoD6FoU7DjTEKvAqWi64eMqlP8E/o
         EfZLKbvfPe6vPBd2cyNSbUC+Br9FNRdRD8vZk9687m3/abWx3xh9eX1vQHAIWV3X6xWH
         anPt56YEoqqx0RDwiygRVP6JXf2m6nytY6d1c0ZoDUMoPbs+PzMNoAFj3jZpQxqv/H5p
         l9Jeztg33QycdCrV1JsJKqPBGtXBzuXJk25OUmbnnh3BCzUH9Xm/VNtCQP0oZZaV4mm3
         yIdEzaea+55P6l2A6JYxnTdILnySQ/yyajwPIjLAnq8cDSYE311xLGytDoi6tHOrPBbB
         pPOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SerMT47P7Y4EGL4Yc5IRC0eutvUHMCX849kOCq3GxrU=;
        b=w1nB/HU5oGkMjq/jYwNgpFxRnVD6jvY36OhN5hXVvV2W1luo0FwODrlSBpi5tDrhnw
         BE2NTLgehMtT0w+nSMsZJNqpYx38+d6DQbQIa/hcTgL+XFm3e0WTtI1XbsZhtl2GdWZZ
         3TvOYGfYJLhko/yFaH7lvrjBQo7MWwKH/GE2dAeXD85K13xWNcACgXb2M3RTNC02nSUQ
         7CK33yVD1aQLSA3+l76qEnVcuwFkoKl8WmpDHRn1nzbW6WoloKBolQWFnbFiQFJYNx34
         vU1GVdXYOzx4jFhXE2qY4xYpYm4aHGlqsY2O5FB+y5AyDp9eI2K0weHsrJuDA3JX+0Nk
         61lA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Z+Z+SjPc;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u67sor11312761pgc.55.2019.02.06.15.21.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 15:21:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Z+Z+SjPc;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=SerMT47P7Y4EGL4Yc5IRC0eutvUHMCX849kOCq3GxrU=;
        b=Z+Z+SjPcNYJWeza2d4b55BxKrkKQit7wzeJhyZ19nOEfLgBL+LxuR3bra3hNQkLyJh
         3GNCn3UFEiulNHorYHsflZuQJc7av2V9iLscVeglodzrgAHwCNK4eumCxcdbIj+Jr0k+
         7YPhPzqWkqQF72g1jQF6FygbuDXYxT27JHxDyrmX+xFHeTUz4t5/4fqsCri56oCi6Oxv
         pzTFJK3BFyZBh6wyNgcSGeIcuxBpYmGk9PeoajJRNtsEhiFLc/+zMkRv0DsEk3rDG/FE
         +D1Ryfi+/ZjJcHQRAnC2yxqzrbq8hsGysmCh3xn8frpPIOIFosWVjEZ1OdJWsEyP8K8Z
         x4Zg==
X-Google-Smtp-Source: AHgI3IaAxkDpETFIE/sxDC6Oen4KkDU2IsiGX44oILKMR/uSR29veBEwrP0zeA/8N9I+tJmnLKsqJg==
X-Received: by 2002:a63:d54a:: with SMTP id v10mr12071643pgi.154.1549495292218;
        Wed, 06 Feb 2019 15:21:32 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id j6sm11829074pfg.126.2019.02.06.15.21.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 15:21:31 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grWVW-0006HW-6I; Wed, 06 Feb 2019 16:21:30 -0700
Date: Wed, 6 Feb 2019 16:21:30 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Doug Ledford <dledford@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206232130.GK12227@ziepe.ca>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 02:44:45PM -0800, Dan Williams wrote:

> > Do they need to stick with xfs?
> 
> Can you clarify the motivation for that question? This problem exists
> for any filesystem that implements an mmap that where the physical
> page backing the mapping is identical to the physical storage location
> for the file data. 

.. and needs to dynamicaly change that mapping. Which is not really
something inherent to the general idea of a filesystem. A file system
that had *strictly static* block assignments would work fine.

Not all filesystem even implement hole punch.

Not all filesystem implement reflink.

ftruncate doesn't *have* to instantly return the free blocks to
allocation pool.

ie this is not a DAX & RDMA issue but a XFS & RDMA issue.

Replacing XFS is probably not be reasonable, but I wonder if a XFS--
operating mode could exist that had enough features removed to be
safe? 

Ie turn off REFLINK. Change the semantic of ftruncate to be more like
ETXTBUSY. Turn off hole punch.

> > Are they really trying to do COW backed mappings for the RDMA
> > targets?  Or do they want a COW backed FS but are perfectly happy
> > if the specific RDMA targets are *not* COW and are statically
> > allocated?
> 
> I would expect the COW to be broken at registration time. Only ODP
> could possibly support reflink + RDMA. So I think this devolves the
> problem back to just the "what to do about truncate/punch-hole"
> problem in the specific case of non-ODP hardware combined with the
> Filesystem-DAX facility.

Usually the problem with COW is that you make a READ RDMA MR and on a
COW'd file, and some other thread breaks the COW..

This probably becomes a problem if the same process that has the MR
triggers a COW break (ie by writing to the CPU mmap). This would cause
the page to be reassigned but the MR would not be updated, which is
not what the app expects.

WRITE is simpler, once the COW is broken during GUP, the pages cannot
be COW'd again until the DMA pin is released. So new reflinks would be
blocked during the DMA pin period.

To fix READ you'd have to treat it like WRITE and break the COW at GPU.

Jason

