Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63060C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:54:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FD0E20659
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:54:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FD0E20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFDA96B0006; Thu, 27 Jun 2019 12:54:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAF638E0003; Thu, 27 Jun 2019 12:54:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A76E68E0002; Thu, 27 Jun 2019 12:54:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 702B46B0006
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:54:31 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id n8so1364954wrx.14
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:54:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=59WT28FypvfMknuE88fzBFdS3e7jn5D+CK2CLSjSTss=;
        b=pXMSd0hvtwp07WNxcaeFxQ78B+0AUgEzVhhrn/jxv+/BASw9U0LsGo6skFxWmWsyIH
         Xl2imU8BTFFYvsPRbeoiJwghIrnbEYeofxxe/jIKj3N+G1Ys0lnhS3WVlBC5S0ubkA8j
         CsqDjEWHvJtzgwTdiZHh8XVAxW1DKSXcDONyt7476Z/MObZZpThBoerG2TTZ7a4Yme4Z
         H6f3hsd5JGBQXTinB2dhioROVljAHzD/DOgyrlymp14Bt/JCP/BoxHHmWkAB7eyjqmb3
         Mu37ZCis18hgwgyZbZiJIAKm06rqxzj8/RFWhwypNxSmydGtco8RBL8aFL+e2eiKlR5C
         117g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 213.95.11.210 is neither permitted nor denied by best guess record for domain of hch@lst.de) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVuibMdNyTE8u469et/YO6M1A2+peqLERV3KZjKEKApNGKb5AxA
	skLCekzYNKNVQXapOm1Ggoq9T6wnRwIyy0fy7cnBoDxT3XNBeA5bYo5gZcrzEJmRhHEKgOk+KNj
	VmIJUrEwc1S5kyGTXQprx7k2E6rWfpySTYYGASZuiowplxe2RDr7OUA9HvyUoLDI=
X-Received: by 2002:a5d:56d0:: with SMTP id m16mr1936386wrw.276.1561654471057;
        Thu, 27 Jun 2019 09:54:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuvlsW4jCv0bMaNel5cYSlKu0i8IlUgD58zjp8C0+CpN2So+u6vqw+04b6k2vm1wfVwiJM
X-Received: by 2002:a5d:56d0:: with SMTP id m16mr1936352wrw.276.1561654470445;
        Thu, 27 Jun 2019 09:54:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561654470; cv=none;
        d=google.com; s=arc-20160816;
        b=rqIN8JTg5AatAAbHUrBLPPe7YYQQ1Mf4gWnuI+MVA76Qt15mVX5JD5QXRBYiRuaAFR
         A0S1z88FhDueNsExEPBM0kWo2kCNGzrYEd1ngGEQqYo0GwByV1TiYSfmLwZp2Q3iahWL
         /vbRQVOgpps+JsLIDpd+ndMJGMXaEUfc5Pd3EdCNwB+CMHZyUxjSrQIXFFjP0dC82bfG
         s/QH6HIYABtIgACKYmi+03r2KXDo59PXp8NS0Z5c+6KLG5GV4FpPgpPB5Iekb8PwFYA3
         Vu7KNRxSOZrbBkyz8w5fjkFyAYfOZfmK9yXAur/OlRLm5nc1q0z37ljx4WkX3JgVoSVI
         ToQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=59WT28FypvfMknuE88fzBFdS3e7jn5D+CK2CLSjSTss=;
        b=FyzKt+IjpTppEWcyYPyXEIYISyvvMljrRsRMla8ymSlGgCI9cVFIAEQkhQZ2Vj7N6M
         eOIyz5h4DEndVe0m9qaTnnmDeIly0v4a0dzzSbFuKn2qVQ2MJlJOzUv0zSas75EZGqQM
         M9OVzl16rmTrm5rOfB00+PGMTGU1wFbvIWmPU+pYr9XmA1RvWjNMvHaXjNC85y/OIHdt
         CIe27UAfVTMsde7KTFC3SKc9SAZthtwuO0yFlf5/PCtTTjnaWqB1o7PcJHXw6/TYw1GE
         urs6vHW5oJqJW0TtmGOvnwzmXYVkxvdYi8iMO0xUZU3+o2mjGVHhorLqUsgxabJ8PzxR
         ZqvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 213.95.11.210 is neither permitted nor denied by best guess record for domain of hch@lst.de) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de ([213.95.11.210])
        by mx.google.com with ESMTPS id 51si2453268wra.108.2019.06.27.09.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 09:54:30 -0700 (PDT)
Received-SPF: neutral (google.com: 213.95.11.210 is neither permitted nor denied by best guess record for domain of hch@lst.de) client-ip=213.95.11.210;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 213.95.11.210 is neither permitted nor denied by best guess record for domain of hch@lst.de) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id D884D68C7B; Thu, 27 Jun 2019 18:54:28 +0200 (CEST)
Date: Thu, 27 Jun 2019 18:54:28 +0200
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
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 03/25] mm: remove hmm_devmem_add_resource
Message-ID: <20190627165428.GC10652@lst.de>
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-4-hch@lst.de> <20190627161813.GB9499@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190627161813.GB9499@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 04:18:22PM +0000, Jason Gunthorpe wrote:
> On Wed, Jun 26, 2019 at 02:27:02PM +0200, Christoph Hellwig wrote:
> > This function has never been used since it was first added to the kernel
> > more than a year and a half ago, and if we ever grow a consumer of the
> > MEMORY_DEVICE_PUBLIC infrastructure it can easily use devm_memremap_pages
> > directly.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> > Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  include/linux/hmm.h |  3 ---
> >  mm/hmm.c            | 50 ---------------------------------------------
> >  2 files changed, 53 deletions(-)
> 
> This should be squashed to the new earlier patch?

We could do that.  Do you just want to do that when you apply it?

