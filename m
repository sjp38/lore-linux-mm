Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AE47C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D57EF214AF
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:51:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D57EF214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 745916B0003; Fri, 28 Jun 2019 14:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CF718E0007; Fri, 28 Jun 2019 14:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56F478E0002; Fri, 28 Jun 2019 14:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f78.google.com (mail-wm1-f78.google.com [209.85.128.78])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC716B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:51:55 -0400 (EDT)
Received: by mail-wm1-f78.google.com with SMTP id t76so1553118wmt.9
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m9Owh7//UnvaH+s5QKM74IMhbp1YkFS0XfYHCY1rN2o=;
        b=r/njeNj/EpicmBV7xJ4ZDZ9f0kFK7Rg/PxMjJScy2eDn2HcHMUSSHZd0MtvpVMDpP7
         JlR98m5+oC1uC6kNlEHPyXJXp3eDo1751FXwuEdsO7KrDwUVqgZkhuypPwlDHEtZfyil
         ClRLduBdwI05+l6YndXjFVmECILQ4N9sX3HOmCej7FxrIzPVaS34ZaBIrfFSDqp74xDD
         e3GsYzTfud9FoG3iIl905prTTz3VRgdXxIaH0ukzUU3xNZbZf3k0KeKpj9kvx0bwE3qp
         41ZIqi10DQZsKTf/J+19dWE4MUPD2Hsz+620J7H1MZVnhIZQOOIUqYOLva5OMEO175yE
         MKKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXEUu1fohkKzbWvmpRflfPBJUZXmTxXtgEAQCEsiQiobHSgquHM
	xpSRzy7iUmn3AOGZiJICejqEVYww6EYKZjiOyIxyN2+9ghm8DzQcSJz8euDKY3pA8D+fS+DLE9I
	CE+jnzj2t89R3ZDWicwehXxTE1cAnJp8U80tAxy4rBXd1eNCYTFWzq4uc2GTlxK9imw==
X-Received: by 2002:a05:600c:2388:: with SMTP id m8mr7701938wma.23.1561747914654;
        Fri, 28 Jun 2019 11:51:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ0c8JYWuQAN5EelXhBzQxpdJDHEliXJQfCxmZgDywkXaoKYTVDwEgMoCp2/Yzp9RGovJF
X-Received: by 2002:a05:600c:2388:: with SMTP id m8mr7701908wma.23.1561747914028;
        Fri, 28 Jun 2019 11:51:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561747914; cv=none;
        d=google.com; s=arc-20160816;
        b=lRIYpbdnvx/V6SI3hu8KLcHHHfljhqxYF+X38pyhGsHYtw7lRK0aYmKJt+0+QeKWbK
         J172DTVHUY15jlypBqxtjiO0k3TZz4MiI6PfKPPTwfw2JSqcZQ1ZdcR5I/qCAvA/v9HH
         0xCQe3Oxbf7aCZG3E2Ql0g0y05pVC/2wB8noXC0cT9IBHLhLB3+LE1U0ncJaJW/oovhG
         mm4c25hmf5lPoHDOPo/RtyiFUe0m0iRvyj5+SJHxz5RFZEY8Zq6EjRQAr2hiToinTX35
         1DwJEWVOAYBuVfCVy4RkoYmidjXVBoVFLAwp9h1E8yqTdq3pgHDHpzgFSsu5OvN/dsn3
         9Kmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m9Owh7//UnvaH+s5QKM74IMhbp1YkFS0XfYHCY1rN2o=;
        b=UinV/hy5bR2dU+hlGM3w6zkfxTpXMllLclZ5iPJpVqde09718W4afzweevfcZsTLwF
         EIEPer2HzPrHuuJ+vp9RDFg7pZeQK8u+OAhIyOZSn+q6s4iJpEVNjQ2vxAsJ27zftydh
         HQta4DQ/QNteXsf/Im68BVjebYx7dXAwFP2WzUbaZUz5++zzdDVlXltwdaUxsuLt3FK6
         SYdcxvazS6Hm+Y6Kp+BiCgR66cS+HxAt9SGU60MTfhYC8UtQYfIX2LGysTmT4ef073le
         u4OXXuYRIjJVATO+4eVLxRcO2bFoqNXVY2egzos+38D/RTYiQ+GikLozMLlX8/MMZZRk
         hqvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r1si2632094wra.304.2019.06.28.11.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:51:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id EDD11227A81; Fri, 28 Jun 2019 20:51:52 +0200 (CEST)
Date: Fri, 28 Jun 2019 20:51:52 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Message-ID: <20190628185152.GA9117@lst.de>
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-17-hch@lst.de> <20190628153827.GA5373@mellanox.com> <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com> <20190628170219.GA3608@mellanox.com> <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com> <CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com> <20190628182922.GA15242@mellanox.com> <CAPcyv4g+zk9pnLcj6Xvwh-svKM+w4hxfYGikcmuoBAFGCr-HAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g+zk9pnLcj6Xvwh-svKM+w4hxfYGikcmuoBAFGCr-HAw@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 11:44:35AM -0700, Dan Williams wrote:
> There is a problem with the series in CH's tree. It removes the
> ->page_free() callback from the release_pages() path because it goes
> too far and removes the put_devmap_managed_page() call.

release_pages only called put_devmap_managed_page for device public
pages.  So I can't see how that is in any way a problem.

