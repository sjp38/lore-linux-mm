Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E89BC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:15:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2064B20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:15:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2064B20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B66366B000A; Thu, 13 Jun 2019 16:15:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B17516B000C; Thu, 13 Jun 2019 16:15:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2BC88E0002; Thu, 13 Jun 2019 16:15:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81F546B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:15:02 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id j18so17385ioj.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:15:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=h8/tgS4M6nq6KoFXrqlTcjd3raqKK1XL5mqvuIHTzww=;
        b=l5MzXtRV72Ra7KFdRP008eiv3Bzcsyq08FeLZh++ndHt3QjWRydCpVtFXqUchivl+h
         1nCjXhdi+3Gh40ng9kBJFoW8IxwiiubCW6nh7/HRHIaIPOPK+EpdSES8lYY2CVSptjf2
         FgNRY+NOGOUjlSHgRWAMVdnu41lfz3QlzOYQFdlSO82PUJM9WsKOLINQtvW+NeNA6dH7
         65QAGzjpaU5s+EGglmV1Jeec34EDycmIYJzzKOcqzuN0SPg8I40JceJyWVY1+uYI7hIE
         bzcv+NEwg3mmmGYYgG0UTn33zGvlQFiFMIMHabau69aRkErwVKR8ZgKK0iVrnVJY9d+n
         Spjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAWEQI9v097y2BaNwZJ4sUwzm+JsdcWCGHLt7go0aNhwkycL+Gle
	z0QjtCzkmpNu0kFpOawkhg+o/6wY9oC25xoGU3SwYAaojoNHC2XaMJKcuKeKLKuSaRi8PYLZakV
	Nt5ggfQXXcLm2BdlNGB0CYmIdp+IKyMthe1/S53G1dNEL/l3+ZDIw9UPq76KJYX4fWA==
X-Received: by 2002:a5d:87ce:: with SMTP id q14mr9566299ios.1.1560456902340;
        Thu, 13 Jun 2019 13:15:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyG2efnxRSd2lePz+QGt1XGh90rWiMwih5IiRvt02QbAp/JSbp2MYKmqtv1WS/GN9v6iJ24
X-Received: by 2002:a5d:87ce:: with SMTP id q14mr9566234ios.1.1560456901654;
        Thu, 13 Jun 2019 13:15:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560456901; cv=none;
        d=google.com; s=arc-20160816;
        b=Qp54nigEy8jJ/nFHwvIczFRIGqFbQbxXied5dDB7yZLr0kO/UXG1Ulx4d6qDmAp+rw
         G2uuVLmZ3imudz/R6uMs3X7P4SXgZaTALkuM4pjwBsgNXJM6CZPQCx7RzUZ/mqz/wLiU
         DlJGq8UcYPsUM7PKryfZ+e2MP/WoPeSJJIbTK65T9PLVcrhcmQbzzD3KMOzubcwxMZAl
         kIOICzlfo750pJHvMf0Oqo37VoU68/CD7+WIow53VVlRNbXNCxjOrV+udHRfDS7x15OH
         JhPUPuK2madc4mc5WzGaX8Sw6IUypqaLTIbPBBwvCHDOhpv/BR50u2T6Ef3Nhz3WB+xC
         ilRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=h8/tgS4M6nq6KoFXrqlTcjd3raqKK1XL5mqvuIHTzww=;
        b=zHD1MHDCKV97eaS0QTAiUj6j9PGINDty1/StuYiMwnsls8KdVJdmSMyeXUky2lPIcb
         gdeO2x38wXbmGR+M/XgQtleTU+CFbXV7DgBYHdAelfz5I0iHtmUHvK9eVllWnclNgIsx
         iCTgyg4dT7XrUwtNAiABE5z6Gc3yB3vJLr6LIRMoJ99KDe3sOhyYe2LeSEU6MoFzVeLl
         790Cn/0JZ+ue+ITMC14Z+3pFPYdOUgbgtlgZprKUlMWxYfRnQ0dbubRDWcx7GIOiyR4H
         MoTF7HtaP0e3MZuLIugV9LxyuEbvUMT4xd80ZvM3TfdpSr3CGX9tQMNPyASo9LVmzlWS
         /gTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id y24si678410ioc.1.2019.06.13.13.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 13:15:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.132])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hbW7f-00041s-Vm; Thu, 13 Jun 2019 14:15:00 -0600
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
Cc: linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
 linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, nouveau@lists.freedesktop.org
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-8-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <4ff7926e-7021-7b7f-93b4-c745055d06b5@deltatee.com>
Date: Thu, 13 Jun 2019 14:14:58 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-8-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: nouveau@lists.freedesktop.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org, bskeggs@redhat.com, jgg@mellanox.com, jglisse@redhat.com, dan.j.williams@intel.com, hch@lst.de
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH 07/22] memremap: move dev_pagemap callbacks into a
 separate structure
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-06-13 3:43 a.m., Christoph Hellwig wrote:
> The dev_pagemap is a growing too many callbacks.  Move them into a
> separate ops structure so that they are not duplicated for multiple
> instances, and an attacker can't easily overwrite them.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/dax/device.c              |  6 +++++-
>  drivers/nvdimm/pmem.c             | 18 +++++++++++++-----
>  drivers/pci/p2pdma.c              |  5 ++++-
>  include/linux/memremap.h          | 29 +++++++++++++++--------------
>  kernel/memremap.c                 | 12 ++++++------
>  mm/hmm.c                          |  8 ++++++--
>  tools/testing/nvdimm/test/iomap.c |  2 +-
>  7 files changed, 50 insertions(+), 30 deletions(-)

Looks good to me,

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Logan

