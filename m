Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B603AC31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:25:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8681E2133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:25:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8681E2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 225EC8E0003; Fri, 14 Jun 2019 02:25:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D6AB8E0002; Fri, 14 Jun 2019 02:25:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09E718E0003; Fri, 14 Jun 2019 02:25:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C42528E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:25:23 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id i22so264560wmb.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:25:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=b9kT1K/9xq7YYfsxrHmey2kZR7xb3vj5Vcj8cPCB6Yw=;
        b=nS74kWe634kMJihpRZ6GtYVtgZ5k28OBQyNjMn0tQjHOnUfSP3RiHdsh+d6EN9apXm
         V8Fx9vHDcDvxwNYkSbl9BN9gc+l/J3TjbH64D3OJQQ4Q732MQqUh4Ssh9Oi+gkOHRo7w
         VtLYog9u1WTWBcjjHedlBxPdqDz08qYXXfh3lBEkyfa5Ux8oRseIg6tpuTbxYS0hslD/
         TwR5wF/CChTmc3OwLzNybkQxvW4lMfh5hgJ/KV4usin9FMDf5YV7/LwUvZ63Y8h/umVO
         s2JBdU87PPwsRKvv11rIi2yBrY9jIGJjRMs68D9GlkiiSkQXNhy2Q3g2kqbUjjso3vDy
         daBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWK8cgaGe0cgo+vtNEsKvdpdfy/FzhDpLFXRYttHEnKZzPGRT7i
	jmoHhU4+5px7dUvOUrz08xr6urRSKYFI7UYNf3L8uN0Y5Id2nf4Nv9xwikj4PEbGcS+cqgGv2Ov
	floGW2t+d3L92IqL0NyOZq3DRKC4NCi8atcqACHeANkOzu6EPnhUHPXsIdNLc6tcmMA==
X-Received: by 2002:adf:d4cc:: with SMTP id w12mr9371926wrk.121.1560493523343;
        Thu, 13 Jun 2019 23:25:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzgqrrC9SbuSbiFSnRuTNJVnShpz0knIkzqUH5e8el10TXGuUL/GUP2Ni11gyjKJaZodtd
X-Received: by 2002:adf:d4cc:: with SMTP id w12mr9371871wrk.121.1560493522606;
        Thu, 13 Jun 2019 23:25:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560493522; cv=none;
        d=google.com; s=arc-20160816;
        b=fWIOh7vj6Sk2AfX2/GXBNSjieldvPUN7FSkf6sMAJOQiTsyIb2eMU0PphibdHdcxQo
         G4R+WSB6tLRs1oDXHx4I1eNf3i+ytcRCWMATrD0mM0oMhREcsYKt6y2VpYTkT320iNl0
         c4QNKoUU1TStWPfAeKo0le2h/tR41WpvkslbKUgCti+8UHP84aeT2NNuDjHYSDR/S9Ii
         5mHcYIDweEzx8Pq1hgOP5/rIsqOLaSpke2TCYWRU8UleP8iJRCk64YUTJvXyxsElV+/1
         oSSHizAS9cYqZHzGs6amwlwOtDUAI0K3/JLV+m3mkm9BsChXW2ZpwV3sGBbiXPe3MA8p
         89VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=b9kT1K/9xq7YYfsxrHmey2kZR7xb3vj5Vcj8cPCB6Yw=;
        b=aFhHCYHFAPU8zx77WHqci8slByeYyRt60N6cZ+giH45kcSVJHugq9A4mOQ4LKI4XWY
         wcsSXc+aOUtxZ6MYw4jhf5zei0nZi83iH9MVNMalthdd1b+/yapCnTgyYx6TLfcYw3qB
         NnuuTyhpNkkEJUWDUqdPty850kBOpCCCUI5vxaT/KRUv5hB0ano6eFvkxTx2HJQ0PL2q
         2v4+J4X+/2KceSQJDVVVMwapj9opOp/fHBZLQwo+8LcJksi1YBe5ifqN2OtEbCX8/MFD
         OEI+d4+noDDM9Ow3GlhDO5t6gOwopId1DvmdQvtQSwzGML4ei9ORDkRhhpWeUsRY0oEp
         etFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e7si5341606wme.3.2019.06.13.23.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:25:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 844DF68B02; Fri, 14 Jun 2019 08:24:55 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:24:55 +0200
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
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/22] mm: factor out a devm_request_free_mem_region
 helper
Message-ID: <20190614062455.GH7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-7-hch@lst.de> <20190613191626.GR22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613191626.GR22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 07:16:35PM +0000, Jason Gunthorpe wrote:
> I wonder if IORES_DESC_DEVICE_PRIVATE_MEMORY should be a function
> argument?

No.  The only reason to use this function is to allocate the fake
physical address space for the device private memory case.  If you'd
deal with real resources you'd use the normal resource allocator.

