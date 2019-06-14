Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F48C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:33:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 596E620850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:33:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 596E620850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA2DB8E0003; Fri, 14 Jun 2019 02:33:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E532C8E0002; Fri, 14 Jun 2019 02:33:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1B4B8E0003; Fri, 14 Jun 2019 02:33:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 955C58E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:33:46 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u2so656788wrr.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:33:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8PO9Ydpr/GVVUxr4C+H3kt9HIjXw2MJwYNSsRclH1s4=;
        b=CSEigc2BV8+aJyF7mEFAXa3Bgmfd/CfD8K3dGXlaKqIanMrb0btZtEALHjAVXhiA3F
         DreVs076tcrBQVOrt3Imo0ozx2dsY4qI/X3eBp9Ps3cHrJfiV9KTwRdjS5FUjgQowcFT
         KJVqSNRc792k50mHPtsaYB9Ll9U9/Eqxil47sn/mwN+7QWadTQfxsn6YXSsWF7Uaylwn
         vL7XK4uHqMyEbzcEy0+KLgTU15BK2k7Ysrfdv4Z1FCYtlPLl4u5OVlBVJKgoWQ69yb7v
         ubv5pVuGZsTq5Z+WQc58orVqTUzgvP6N9xiJ94PV4wqm/F4Qt+GEuObDQ5rNqdBRpWYF
         RvGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUiApa7pi9LB4wW2ndOb9xW+MdyxsJ7ozzHrw2boBM78c4Jx08R
	UK3mLpYDnI22GUdu8qK42z+sL8TL1D3typwpfwfQQTAvTVYYkZacYETFDaMfMzRT4JeBGWLtXcp
	KXH0e1Vr+dCUpGMVhAPoKfnsS6zZDIv0CIaJh/YL1X71IH6DBWr1Jk6SAM/jIULKpWg==
X-Received: by 2002:a7b:c775:: with SMTP id x21mr6383918wmk.9.1560494026158;
        Thu, 13 Jun 2019 23:33:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBlzrKF1RCTDPd9GC4vvfW6YO7mZCRCEMZTS2s3omw6Vaq3GOJ75EIUsbgR0UPQWqlvyww
X-Received: by 2002:a7b:c775:: with SMTP id x21mr6383882wmk.9.1560494025457;
        Thu, 13 Jun 2019 23:33:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560494025; cv=none;
        d=google.com; s=arc-20160816;
        b=MDMY2WQSsl0oN8LkcQeY9AP6c6BAM5eVEnBuN2JtjnherLtw4zKerQFGAcSI6PfHw4
         ZGEU1BsztaqMOGBWsDugzbLpb6gQA2YTroAnUAICf+IjxTs6ieLg6v6/0wAtnKjiz4SN
         21UsgS9Qwy+oWp5MzaBwB5elar4btshHoe7/qZmoEZZys8DSninQKW5Sy3anNQzH7quH
         /b4I7kMfr9LAA6VGhZkFw3b/IvvwexE7bUF4H2oAb6SbO/JGXJ6I/xxqUn3H8fk1luR5
         uiV+72GUf6PTBCixR1yPUWudTR6GlQIurj1Fua/jOS6x2pI0ProIQVenD8TqvjdqYkRQ
         FcqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8PO9Ydpr/GVVUxr4C+H3kt9HIjXw2MJwYNSsRclH1s4=;
        b=XC8pWRwlRhSpt0jdmvdzFl6fi0ylMHuNF3Yjmb5DLdRoHgE1pFlBWiiT+t3GQLdf3+
         55wKoC1P9qfuSZdHwEFiFAsZfJTS/dletvYxAjPvM6WV0EM3xB7Rgl8I7M/4nuIdK63V
         yrrPe1DxxntHUMf5VU/b9ZMaRio7UvIV5b1OPLonSs9xIJklTSY6L6+B8I5MDwNSk7+r
         vrC63bXR43UPSedtw2NwYFzRgxFmQ1TLuAw2XtEUghE/aZDDbn2F4CeyBAomYy+xeAwo
         sxN9+LuYy4nvzUXqnKTmdTrvRvXFcRJ7ew5COh7TOFkvbvPpogFWv2XJjvaD0eX9dJ5K
         xg/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w13si1938181wrg.9.2019.06.13.23.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:33:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id DDC1568B02; Fri, 14 Jun 2019 08:33:17 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:33:17 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 10/22] memremap: add a migrate callback to struct
 dev_pagemap_ops
Message-ID: <20190614063317.GJ7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-11-hch@lst.de> <d6916d71-c17e-74df-58f2-c28ff8044b96@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6916d71-c17e-74df-58f2-c28ff8044b96@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 04:42:07PM -0700, Ralph Campbell wrote:
> This needs to either initialize "page" or be changed to "vmf->page".
> Otherwise, it is a NULL pointer dereference.

Thanks, fixed.

