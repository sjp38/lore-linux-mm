Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEE36C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:51:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABEEA20657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:51:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABEEA20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F0628E0004; Mon, 17 Jun 2019 13:51:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57A068E0001; Mon, 17 Jun 2019 13:51:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48F678E0004; Mon, 17 Jun 2019 13:51:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEBCD8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:51:30 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b67so185344wmd.0
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:51:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Zc5iEicVP+GPxOw79f+rKpOwABK7rEwl3KRTDl+e+Yc=;
        b=txgxYevNwQkptBMi6h90749KK/q2UfUBfvHe5t00JVfuAX+iumjxvL9TbYvXTNJ0pV
         VxsiPefTCwkZ7xnir7i8o9MgG2VRDIgLHs4jP74RiAaDhyP/xXeDsz8krg7YH2xeAvCT
         4SNwK2IY/R5cLQQnlNvI+08rs7cStHIvMPpKbHRj9ltrCmb2qs6LEdnQFIpycGMsLdDZ
         qvUclwkVlHIQ8sCC+xNnd87/tyWuR4i5OYvJZ+kH97+XONDC6Qn85OHWoP7Zs0YZyVnB
         Eri6u05cdYSPV5BEjugcizuUp/uJgQpSjVSy9yn6+Nfns3F/8XX5yf33tIBJfnchxQR9
         S0Ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVvyeNZCSM4XMqfUoGJs/wHZfBkJV0Ey1X2XjHDJEUMHYccjLF1
	dPLAKbc4yfdJTo1OayRUua89KUSkoIzxRrgxPWqWutVRWg02UfNT/zY1+WnnPN4XBfl8kdynn9q
	XFpHiIkm8p39xlWia5wSvuu2qbx0kxJxSHR21iq+g6C7fSNYVKCmh2KCf9um1M4zQlQ==
X-Received: by 2002:adf:db12:: with SMTP id s18mr24246423wri.335.1560793890546;
        Mon, 17 Jun 2019 10:51:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+FChRHMZKE8OCH/Mj3hP0f/5GdJ19jHS/CeLQLCGFwFxrW4/CP5ugzkW/AETa2CKS6nfJ
X-Received: by 2002:adf:db12:: with SMTP id s18mr24226541wri.335.1560793400899;
        Mon, 17 Jun 2019 10:43:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560793400; cv=none;
        d=google.com; s=arc-20160816;
        b=Jhky5dzLAsj4xVoybSJlROc3GbOSe1UJD9BoDtUCIUNzF76uVwO/rpBZak5Qo9l9KK
         y7neMqgdM2QuoCplrdxF/4cCNeGnqAOO9Z7ncRMd4M+IQ0Pq8MSscpL1X33HlQLWkkdh
         T+wFOIJDzF61lKOyg/cAY0l3V2LoIikgzU7gj2JZKIaqGDsDGxmXOUGfI1dSHP78dDFG
         vC17VOCGFP16JLp4CZKnSngW6ZZ+YakUsa1S5+8FFg8yDnJiS5szp2D7rf1xx/p9j8ZK
         DQX9dOIHQ/UqapSmFB1NizQVDEfz0dLhGwnGvwsIdERx2bjRUjpD61Q2L6a3x2zpHOXJ
         rLfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Zc5iEicVP+GPxOw79f+rKpOwABK7rEwl3KRTDl+e+Yc=;
        b=Es7iaXVLQ/fXC/Aig/JKf60FxOzcXtXTJSL8/5Dyx+ZkJG5FvWaEectyRUGTduDQCl
         7Ewy6/+Qzlci6eG5lh46tE+ogYFkM6NuPjhTvpvwwqjl+DJmiHdwAB4dzWuw3I8+inqJ
         IPK9IaXxHd56da0JD9fK9Uejs6Xs5KflgsVfp97JVmPA7KZmFEB2NIeBeWD0cefW2pua
         tPoOWnNxurhAj98QKyY2NOOZe7nPboB1YE1erxOalh441hicawVCtLMoxshwdQrWpkgi
         PuR3IG1rZpxq9XVov8xjBPC0Ss7UJOr7rr8h+23O/L1n9tQRUAAo3FBUuymWr/n4xjDN
         v25Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q14si4660492wrn.453.2019.06.17.10.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 10:43:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id EE36B67358; Mon, 17 Jun 2019 19:42:51 +0200 (CEST)
Date: Mon, 17 Jun 2019 19:42:51 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 06/25] mm: factor out a devm_request_free_mem_region
 helper
Message-ID: <20190617174251.GA18249@lst.de>
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-7-hch@lst.de> <CAPcyv4hoRR6gzTSkWnwMiUtX6jCKz2NMOhCUfXTji8f2H1v+rg@mail.gmail.com> <20190617174018.GA18185@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617174018.GA18185@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 07:40:18PM +0200, Christoph Hellwig wrote:
> On Mon, Jun 17, 2019 at 10:37:12AM -0700, Dan Williams wrote:
> > > +struct resource *devm_request_free_mem_region(struct device *dev,
> > > +               struct resource *base, unsigned long size);
> > 
> > This appears to need a 'static inline' helper stub in the
> > CONFIG_DEVICE_PRIVATE=n case, otherwise this compile error triggers:
> > 
> > ld: mm/hmm.o: in function `hmm_devmem_add':
> > /home/dwillia2/git/linux/mm/hmm.c:1427: undefined reference to
> > `devm_request_free_mem_region'
> 
> *sigh* - hmm_devmem_add already only works for device private memory,
> so it shouldn't be built if that option is not enabled, but in the
> current code it is.  And a few patches later in the series we just
> kill it off entirely, and the only real caller of this function
> already depends on CONFIG_DEVICE_PRIVATE.  So I'm tempted to just
> ignore the strict bisectability requirement here instead of making
> things messy by either adding the proper ifdefs in hmm.c or providing
> a stub we don't really need.

Actually, I could just move the patch to mark CONFIG_DEVICE_PUBLIC
broken earlier, which would force hmm_devmem_add to only be built
when CONFIG_DEVICE_PRIVATE ist set.

