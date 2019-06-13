Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E1DEC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B64B2175B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:17:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B64B2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0DD96B000C; Thu, 13 Jun 2019 16:17:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC05D6B000D; Thu, 13 Jun 2019 16:17:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE16F6B000E; Thu, 13 Jun 2019 16:17:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2CE86B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:17:57 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id y5so7844ioj.10
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:17:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=g5vfM/mXzZDGS8b8HACyDXj5tc4R2y/flvEDDeE/3Ak=;
        b=TVbGOVo50sm5V4XTiuL7Y4kGTD7R9u9DvIOLxBnUnD/IQFaVcJ0/mSaoGMBx0qBupH
         5GzxF3VZIxq+3ce1IXvGO5Hk4Znav216aV+ULraFaG7xJkYqyp+lyJUcif86d7WPSz+L
         NC8ogPeo4sHYAHhpm3jM0v44PUR+5+e8m7tpF+OGhGjNbU2Sh5zvwPVFBbDwWjrWHFkK
         m87Zy8u/nqUBQFG58kSzdFM0fHFOBn3JrF/dYTmjoOSSeC8p5rDAsYxLWNBtuMc26oqf
         SbbGPYPTNKVjFQr8cjoP/FjjY+qdI9PWd51qlP5rE9ZIQYW+4UqmjzUpRatFPzXE6NaQ
         238Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAWqCHaFnJDUQm5pOug+ZRgO83boF/1tdRpMJBhRjRpi3Hh72cqL
	AXK4Q+tuWEED9gTEwXlHocKEc8LUZdEq72WtK58s4Sq4Px1n4WFMrj+gXYJfJxAkA6mRzkuxiVx
	TtoErWjtZQst7uzulk8LGD/l93xEW29oXp07vOjecrZib2jxmDZD80AfuCdBObyAXaQ==
X-Received: by 2002:a05:6638:40c:: with SMTP id q12mr11235094jap.17.1560457077431;
        Thu, 13 Jun 2019 13:17:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRrfBIHORWGl7Mkql5glXtrMMNzjAd9/t+5YMnFsw4Os+qPgPPmsvAEP2jZi4cOjmZHd/0
X-Received: by 2002:a05:6638:40c:: with SMTP id q12mr11235022jap.17.1560457076790;
        Thu, 13 Jun 2019 13:17:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560457076; cv=none;
        d=google.com; s=arc-20160816;
        b=UqUpZkgzs3jhELHc5hLphse6PFr2WEhhFQ4yINd59LqcBIzljYtLh8hy8dqX5j1W++
         GrMRZhzzsksNRNxSUz3BBEP0T9qUC7RIpDHXsC/2L3fOh4py72+oqHCCf71jjm2VABY4
         0DeHiht1HGF0RgQzYhBfW0DzV4PAPcrNziJ2g/JfqWcffOeJWvPLl2byrQ19dPPe1Zyn
         AicpXb7XwRNDLlAM4N91xDzBTSMAA7ums9ewuZbCynY05uraYKiwaT/DTGnkTHLOdqfU
         tjS800pKEkkVvZ1hOEBvrDVsuPbFBOd6d2rMYqfo6RXcI5ugjrGo1+oUau5xrdrU7rsp
         HevA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=g5vfM/mXzZDGS8b8HACyDXj5tc4R2y/flvEDDeE/3Ak=;
        b=aTnJO8RURU62U7PgeGc6dOeDjkss/z12sELYsUeqmnbxCd8AgTWLEKmhp4MQELFyJ3
         6OqeYh4nftekwkoagglPtBDGDcjsTPwvywbnF73TVo2lhfgH44yzSShCsrnq9KXMorPg
         Z0J/QNSKVppatmufZtbvx85PplxdEoRMYcWiRpCV5KLX4H/wNOTqcBv4aasPpTk+B0Nd
         XLpGmcASLGmS+k3q017MbYTBj11hJzVAC6vWo54ybm7GBHiXS5iY/pNDKw1XzdeEIAVF
         hjzD03vXDsQbHKqk6eN+/J9ukIYVxWqxJSqRT2O0GMbCjy080qeaf6URH7rord+CTlK0
         AZ1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id c3si626616ioq.99.2019.06.13.13.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 13:17:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.132])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hbWAR-000445-8D; Thu, 13 Jun 2019 14:17:52 -0600
To: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, nouveau@lists.freedesktop.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
 Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
 Ben Skeggs <bskeggs@redhat.com>, linux-pci@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190613094326.24093-1-hch@lst.de>
 <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <283e87e8-20b6-0505-a19b-5d18e057f008@deltatee.com>
Date: Thu, 13 Jun 2019 14:17:49 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: akpm@linux-foundation.org, linux-pci@vger.kernel.org, bskeggs@redhat.com, jgg@mellanox.com, jglisse@redhat.com, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org, linux-nvdimm@lists.01.org, hch@lst.de, dan.j.williams@intel.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: dev_pagemap related cleanups
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-06-13 12:27 p.m., Dan Williams wrote:
> On Thu, Jun 13, 2019 at 2:43 AM Christoph Hellwig <hch@lst.de> wrote:
>>
>> Hi Dan, Jérôme and Jason,
>>
>> below is a series that cleans up the dev_pagemap interface so that
>> it is more easily usable, which removes the need to wrap it in hmm
>> and thus allowing to kill a lot of code
>>
>> Diffstat:
>>
>>  22 files changed, 245 insertions(+), 802 deletions(-)
> 
> Hooray!
> 
>> Git tree:
>>
>>     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup
> 
> I just realized this collides with the dev_pagemap release rework in
> Andrew's tree (commit ids below are from next.git and are not stable)
> 
> 4422ee8476f0 mm/devm_memremap_pages: fix final page put race
> 771f0714d0dc PCI/P2PDMA: track pgmap references per resource, not globally
> af37085de906 lib/genalloc: introduce chunk owners
> e0047ff8aa77 PCI/P2PDMA: fix the gen_pool_add_virt() failure path
> 0315d47d6ae9 mm/devm_memremap_pages: introduce devm_memunmap_pages
> 216475c7eaa8 drivers/base/devres: introduce devm_release_action()
> 
> CONFLICT (content): Merge conflict in tools/testing/nvdimm/test/iomap.c
> CONFLICT (content): Merge conflict in mm/hmm.c
> CONFLICT (content): Merge conflict in kernel/memremap.c
> CONFLICT (content): Merge conflict in include/linux/memremap.h
> CONFLICT (content): Merge conflict in drivers/pci/p2pdma.c
> CONFLICT (content): Merge conflict in drivers/nvdimm/pmem.c
> CONFLICT (content): Merge conflict in drivers/dax/device.c
> CONFLICT (content): Merge conflict in drivers/dax/dax-private.h
> 
> Perhaps we should pull those out and resend them through hmm.git?

Hmm, I've been waiting for those patches to get in for a little while now ;(

Logan

