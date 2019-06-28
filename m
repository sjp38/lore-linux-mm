Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0B88C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:59:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 648E0206A2
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:59:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="w73nxePK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 648E0206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F08376B0003; Fri, 28 Jun 2019 14:59:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E91588E0007; Fri, 28 Jun 2019 14:59:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D329E8E0002; Fri, 28 Jun 2019 14:59:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f206.google.com (mail-oi1-f206.google.com [209.85.167.206])
	by kanga.kvack.org (Postfix) with ESMTP id A629A6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:59:31 -0400 (EDT)
Received: by mail-oi1-f206.google.com with SMTP id x72so2960374oif.13
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:59:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xZKi8dPs5bce5TA+lDYDR67LZgo76bXK/epIzKFvivc=;
        b=QRfDZHiX8GF0a5ieGXeviDOzUfifMhXu0dZxBk3F21X1TBYBFStlVCHpMtPCOOtVwk
         g/0RSW152vzbRkPcncT2oUPtJ0D7H/r8tZZpSmD48+lJO8sTYwCkQX8pZ0xs4Omyf0CP
         kFiPS/NUedJg7ohL5yq/NrdVIPlYCrQwcQohufwDiNNTlWc8d9p+mEG7S0mL5mnF9lvz
         xAkBuwr+24BxpOawReEhOg3LRYv9S+IC6tR2cxlfDvCdeYCCHdTqYnHruYJm7LJLs2vj
         c9hHpglXz81ukv5dic7pJPn+kXQeW3QVa8d22h3x7NwnotVcJGqjRbVUdFqye9ZRbRku
         0dhQ==
X-Gm-Message-State: APjAAAV8PYP6sn9tifu/hln5/2d4LXGVNpjzH0tnLlnRqsULMT/9WZp8
	9p49WELYQ5FTtg6ScQsOJAWjz8hnFz1Pdx0jxW5GBdRR1oMPk0OqZI78kHvQDAMT7tVRgtyqvjU
	9byRYRnTYVhpnybpr0Y+9SktE/ZFgJtY1JycyyGrhrirbsPgBKHk8deu8BMOf7I7LfQ==
X-Received: by 2002:a05:6808:8c2:: with SMTP id k2mr2494366oij.98.1561748371201;
        Fri, 28 Jun 2019 11:59:31 -0700 (PDT)
X-Received: by 2002:a05:6808:8c2:: with SMTP id k2mr2494349oij.98.1561748370642;
        Fri, 28 Jun 2019 11:59:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561748370; cv=none;
        d=google.com; s=arc-20160816;
        b=OtChZSxQFTelMv2+FZ6TgQN4WNOxHhSQVxRcrKrsVL1cD7N5YJ4qHyqeNbJL4PahZd
         SyEZI1ZpDxkwZrM1cxqUd+defo8j7aGHy6NYsA+5d9j8uy4E1nH20wN1ikSES3koUKEJ
         1kiRlEtftk/m/Bab9tvoaLjrVFrLbXHb6PEAVKWS7cmPUTz+Y6igy1oHQweCQVQP2wLj
         pdFKRpNrmjzIJAW4bBF6Hs3H0lhTb4IPjh/lg6xxy8/F0gS23Gov/Jbq8l6psSjLiC47
         F2yeC7APPNp1JPkSyqlucAU11IY8HE5b/nNtqopTaW2ut9XOwHnCJMAkj0qyBoQeqI3i
         GWkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xZKi8dPs5bce5TA+lDYDR67LZgo76bXK/epIzKFvivc=;
        b=yMFLR/PwzHTKV3M7T8bQOgQNOyofX42eWSVNmZ8bKjstbSm5CcDzo/dEgo94i+pk8e
         s4UnKGjQMMKDr2uwNYzZxSYyC73QCa23QTPDs0Sk3mdN+OSHEaJYH8g6i5OBTSBmWpF6
         HSBqGFvqLJIgm22XUc8tGf/GTQb31jZDK6PtCTgqvVO4FBPXvkTWqzlDnl2bDcGuvNuD
         EB/4a5rBpURs8/At0wGk7pNmVmrgAtcvO+4PsmtYhtX6+uS5GVzxLkXTVNHDaLgf0g/v
         +jtoxLOMMdKna5GOGRaaqhC+l7427lpB0ACdSkKwOf+6x4D4sfWCa4LIVe4ALuE82bDD
         ceqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=w73nxePK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17sor1622880otk.82.2019.06.28.11.59.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 11:59:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=w73nxePK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xZKi8dPs5bce5TA+lDYDR67LZgo76bXK/epIzKFvivc=;
        b=w73nxePK59nSfEruxrF1M0kHpQTfXV+T0BR3rvgPNUWzxDsJQPeaM7uFD7eKRrxE9Y
         9ImwGmBtt6yXJ6nlctHx0FbYi1ua/8g/5ZblEqYZrPEU8IkQx9AAwyacMH73KkUPSZW4
         2CnxLw8FBn5LZR6QuLzXXkPegk+n9WnVTkvOy7EQwUeDTJ/KqrjyTyioxg0mlKF5l5Fl
         pBgbtoepm7/tvV+XTP8uNL6F6V5682w/nGp9yu+fmrqAAOl3CXi6A8E63DaUmygnIHBK
         Lo3TxfO9CsdVEHmVkApvqnki+XHSFnPPV047Ep963nO0SUi6VwELdrivAHXWP8JUXEYH
         XM8g==
X-Google-Smtp-Source: APXvYqxUAlE0PhQVf+kI2qGh3xwcV/BdcPGn6HCqEnYJmqo0MIx4gI+EfnCAuColBmsblnHh366HyPqaX1Z8NdWYLok=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr8858325otn.247.1561748370285;
 Fri, 28 Jun 2019 11:59:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-17-hch@lst.de>
 <20190628153827.GA5373@mellanox.com> <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
 <20190628170219.GA3608@mellanox.com> <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com>
 <CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com>
 <20190628182922.GA15242@mellanox.com> <CAPcyv4g+zk9pnLcj6Xvwh-svKM+w4hxfYGikcmuoBAFGCr-HAw@mail.gmail.com>
 <20190628185152.GA9117@lst.de>
In-Reply-To: <20190628185152.GA9117@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Jun 2019 11:59:19 -0700
Message-ID: <CAPcyv4i+b6bKhSF2+z7Wcw4OUAvb1=m289u9QF8zPwLk402JVg@mail.gmail.com>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, 
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 11:52 AM Christoph Hellwig <hch@lst.de> wrote:
>
> On Fri, Jun 28, 2019 at 11:44:35AM -0700, Dan Williams wrote:
> > There is a problem with the series in CH's tree. It removes the
> > ->page_free() callback from the release_pages() path because it goes
> > too far and removes the put_devmap_managed_page() call.
>
> release_pages only called put_devmap_managed_page for device public
> pages.  So I can't see how that is in any way a problem.

It's a bug that the call to put_devmap_managed_page() was gated by
MEMORY_DEVICE_PUBLIC in release_pages(). That path is also applicable
to MEMORY_DEVICE_FSDAX because it needs to trigger the ->page_free()
callback to wake up wait_on_var() via fsdax_pagefree().

So I guess you could argue that the MEMORY_DEVICE_PUBLIC removal patch
left the original bug in place. In that sense we're no worse off, but
since we know about the bug, the fix and the patches have not been
applied yet, why not fix it now?

