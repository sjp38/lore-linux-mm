Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFDA5C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:55:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76ECC2084B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:55:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76ECC2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0162D6B0005; Mon, 17 Jun 2019 15:55:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F086F8E0004; Mon, 17 Jun 2019 15:55:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCFEA8E0001; Mon, 17 Jun 2019 15:55:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A23E46B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:55:55 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id w11so5087142wrl.7
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:55:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=VzcQy6t66AEW47ZsnVicwrW+nbzN0qh9lPebcIPY+nQ=;
        b=T33vZEqfPXM6U6JJmQ4S6FpC0B1OK7/xMN6q5SnZU10HaxSY7X35eKt0mONJ6XcV+3
         l9/uIeB3YpU342oYdEdEQFvIz+fBue0iPuNL1FQ3b3YLShuGny5spnTC03X0mWuTZTPk
         FCwtZbK404QiEitZHWfn4WIYz0aKIjy1U0MUg8Nv1+SabaIEoIk0DfsQmw0qAcwZfZv7
         uRm/RHh8mr3gu7W4oBwe3pgSLr0ils2lZ5aS26NvdnrIh0BM9F4dfuqouCmjG49obNhm
         89demUgsSvORo/mNs4FLRn4S7pZNvQMZF88CYazdBChgz01kQTszeUH/zFY2XKOMOjpJ
         MKsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAV69TLU8yJQQtrnABzvzl+3q4ClaXqfPNanK+S5Fyx5wg85aVoZ
	6d1VsKXlPdA0YPyEhDLkr9t8Wb3GV6zO1EDGB2OrwepfJZnlYK9AGrQGQ2iOHRk/NeUEIw1NaWJ
	c5AwnlMRY4UJ6ED+6wWL3+/352A3g2pa3hbxd5gdWNjzLUZ8flJfV2ehxEVnyS0kh3Q==
X-Received: by 2002:adf:df0b:: with SMTP id y11mr18059239wrl.176.1560801355260;
        Mon, 17 Jun 2019 12:55:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1NY/xYkRp0C9yIbtWAI9FYjiDAJco77ecwdRF7tAtQU/rfti08jeEPo+Zqf+Ef6rEf95B
X-Received: by 2002:adf:df0b:: with SMTP id y11mr18059217wrl.176.1560801354676;
        Mon, 17 Jun 2019 12:55:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560801354; cv=none;
        d=google.com; s=arc-20160816;
        b=s8r0gR2XvXAC0/rAOTR1qXIXHYs5YDNiiSQpuTxDq9HBQZ55qWR+vGtTiGdaOctrqF
         akzt11Gi2LUCA3wq3Y1Uv9MgBoiaGbtrBJ1PnNoZx9eGHb3JlgDJqWJRhGbz0oOw9kKy
         J0MlSVbcV3HEm7NzdzfuK87WZHRFQ2b/l3MydOycYbUCnse2a2EVcmudDPefoq0q9Ub6
         +VqZUQ2GFj1d9geT+KJ1NP4+K+blYasn7XJlESXGWJTd/3drfd2ZM8UKqLvcXsyP6FBI
         oZp/BfcQJeE5wj6KHgp97TG8Emrrr5r/U8yddEMqbcNxXIF/4JxdUtMN6rIiZHBpp1XE
         mINw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=VzcQy6t66AEW47ZsnVicwrW+nbzN0qh9lPebcIPY+nQ=;
        b=sitkb/xhhAqL4LM8hH4x8//MFiELkax8zLv0GmFWr9SIlaIsNJj9ElWSxUCWjy1/hF
         m1iVFKQBfM7jdwuQRZbHGzGedzq3uCvPN4IsK9S1K3CyvwEfcVL7XdaO0zaUWb78w5Rb
         v+uejMMqjEjUbziSSbtUdT79MBlAWMyM3tvqCFLmtTQ9twOAnQC/YOc3isrT/eUxsAn1
         VB4ckUYR/XXWSKLegs6+cGkwjqhcXWA/DfXxjwR4AAoE12jkzCKfF9XZYi3QpQ3X8peR
         x7MvfhNYhopyQaFrFFCw2po81sR3/+tJ8DGZUDCok32mGapgehUxSx7aDYjMkJNrVVni
         Dmkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k14si8285021wrl.437.2019.06.17.12.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 12:55:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 82B6768B02; Mon, 17 Jun 2019 21:55:26 +0200 (CEST)
Date: Mon, 17 Jun 2019 21:55:26 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH 08/25] memremap: move dev_pagemap callbacks into a
 separate structure
Message-ID: <20190617195526.GB20275@lst.de>
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-9-hch@lst.de> <CAPcyv4i_0wUJHDqY91R=x5M2o_De+_QKZxPyob5=E9CCv8rM7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4i_0wUJHDqY91R=x5M2o_De+_QKZxPyob5=E9CCv8rM7A@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 10:51:35AM -0700, Dan Williams wrote:
> > -       struct dev_pagemap *pgmap = _pgmap;
> 
> Whoops, needed to keep this line to avoid:
> 
> tools/testing/nvdimm/test/iomap.c:109:11: error: ‘pgmap’ undeclared
> (first use in this function); did you mean ‘_pgmap’?

So I really shouldn't be tripping over this anymore, but can we somehow
this mess?

 - at least add it to the normal build system and kconfig deps instead
   of stashing it away so that things like buildbot can build it?
 - at least allow building it (under COMPILE_TEST) if needed even when
   pmem.ko and friends are built in the kernel?

