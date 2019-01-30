Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01656C282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:00:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAF6921473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:00:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAF6921473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CB6D8E0003; Wed, 30 Jan 2019 03:00:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5538C8E0001; Wed, 30 Jan 2019 03:00:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41C768E0003; Wed, 30 Jan 2019 03:00:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD8B48E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:00:08 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id a11so6760222wmh.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:00:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xZSgWiNBQ9mrPvNDImvMeqZ7ZyFvATCOQEBhdh+uC3A=;
        b=OEEZ5Ffc7Q22W0Gvb4LhaX13fUBnRzAtvjbazT9V9NlRk3ylbKM4lozWPHlNHv0HMJ
         NT89O4+MMlSgouNgkEbMr8PBddJp0AzgWTV06NcHcv+lch7sykOaoqaQXFaPj2qNrDSK
         YoEYxG1TlA++M6BgeZXz9IjLgT/7CWoO4AzA4V+o9II4klGlqPS8b1LFGMrtidTmAzGT
         Ou6UtHCFpzfUFlKu8rUtnvQeUxADaXy8rxMwCb1fA7v0RHvxhWbcScWlKD8/9CVimmdf
         /a0NROdXV/gRXEihdXm46UH18SRnh3P1hWHvaqn80Gfc2F2x2FSydQm4jGKQg1nLlx07
         CRgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukclRJoYkfS0J5C67b5ptEaWR8wmdnJylv4TipGXGAsK/F5JSumW
	jLffPzVmAHpzHW4IgZ/ZGtUrZe3ZNeSS+NPNCwcFHReXVLN5Joo57w82DzL2wGquOZ2thriCG1V
	OfJKw9XEX5fIjh0QO4DrGMA3Z9/L6KcFBhIXiRgCQ90jiQ+3PlF5QDwAj9lb/zpRzmQ==
X-Received: by 2002:a1c:8d53:: with SMTP id p80mr25403306wmd.68.1548835208460;
        Wed, 30 Jan 2019 00:00:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4U6wdLzUBPxyfgHw61IBvig7xXxdDlOCIy2ol7sKzYcK7Pok8F3gldggwJNBUT4WCvAHQ7
X-Received: by 2002:a1c:8d53:: with SMTP id p80mr25403203wmd.68.1548835207304;
        Wed, 30 Jan 2019 00:00:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548835207; cv=none;
        d=google.com; s=arc-20160816;
        b=pznZFvlOzaJGfGAwKPUonmovoqAyooByKXVC2D5RcKIx59juxuYqZlbZOYm7eHpLrq
         8FbqL3hiKArNvPXq9OOn3CdEqEiLVMNaBFlHm/8PhqQ7ZQbZxiH4g8BVw9yUED5DIN+z
         EMHOAhwCnxlwaO9pIvadHmvrdJSlMe6uqTrYqEwOnwOxic1dLFdNGXwgNjJnx5uFlEKQ
         78Z2Mh3E0zDdstLLZ9MAD6EW+eJn44VZUIum5WRhP/mSoLfH+ERUOF+aEoUnjbZXlevE
         iozWXvFOQFG/4lU5aLlKqbmEkzQOW8/BFQJMzG9G8S+W4GxHZKUouVPXSFB4mnxi5Kst
         2/Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xZSgWiNBQ9mrPvNDImvMeqZ7ZyFvATCOQEBhdh+uC3A=;
        b=yn7nfCWXKx3ju4tF6kMMd9qrIi8hIl+JgqYV8MqwJ8SJbJF/9V3uA8hcyhTrZZtIYJ
         MPRnwDmm9/qi2UD7bSZPJvV1lV8qZnGhIyD1B7BeCAXOLnFmygsl6yd28YxIZMSjpbEK
         rgFteFLN0ZwE1jyU4fUDw5e6rZ9H9ekMrQSvrNuTIRWQeYV1LMwP19726Yfyh9u0WxqB
         37WazrFzpkhqdpVAsO+hp1oQ+iEL8QOgvx0edr1wfSoOwDT3eH95M4NpVZgss8Xp5fCi
         ahM2+YwYDbYq/xEQ1gFSkNgUcIeewoscASmojQn82+QKz6HYjYiKZx8uHYOnmX2+/KQA
         5/XA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q24si468138wra.304.2019.01.30.00.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:00:07 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 65FAD68CEC; Wed, 30 Jan 2019 09:00:06 +0100 (CET)
Date: Wed, 30 Jan 2019 09:00:06 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>,
	Jerome Glisse <jglisse@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190130080006.GB29665@lst.de>
References: <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com> <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com> <20190129205749.GN3176@redhat.com> <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com> <20190129215028.GQ3176@redhat.com> <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com> <20190129234752.GR3176@redhat.com> <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com> <20190130041841.GB30598@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130041841.GB30598@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 04:18:48AM +0000, Jason Gunthorpe wrote:
> Every attempt to give BAR memory to struct page has run into major
> trouble, IMHO, so I like that this approach avoids that.

Way less problems than not having struct page for doing anything
non-trivial.  If you map the BAR to userspace with remap_pfn_range
and friends the mapping is indeed very simple.  But any operation
that expects a page structure, which is at least everything using
get_user_pages won't work.

So you can't do direct I/O to your remapped BAR, you can't create MRs
on it, etc, etc.

