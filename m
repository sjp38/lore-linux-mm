Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA78DC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:15:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B6C120B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:15:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="HiQM8Oj8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B6C120B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12D456B000C; Thu, 13 Jun 2019 16:15:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DF0D6B000D; Thu, 13 Jun 2019 16:15:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE9736B000E; Thu, 13 Jun 2019 16:15:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id C60676B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:15:26 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id p83so8166oih.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:15:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gYvi3JENt5xjT7/oQoCCDRRyhuGQKrPeHYLl1e4tUxo=;
        b=TZ3KtP620yALhIZEUl0FDz4L1SwqmusXPo7zhMB1xvxBTXmyXJ65j3mVOHedcFOHrE
         f9SbzUGVYolqd9xSgv7CJTb9NUps/DzkMTHqipy8nyMN5ZQhPQazxmNKTBMNW9LsHvbW
         Z5WGF5U7WglvqU9xhbM7hY670OUJXsJiZgTKI2nyuUNZjW9t+b0yneTdeGrjIp0vb95R
         M43aoVjxScQ7DkFINy+5Ge+UTDGNn3/v48glKlQKSArfAJNrhAxXn2aPOj3sqPyt7/xU
         66H9ToVcP+ZgDN9b5Aom5gaZKcNigXIg3JhW2++1+qIfxJrGTpssl1Ath7g7Z64Uq8ee
         jnjA==
X-Gm-Message-State: APjAAAUs1JjnVM9j+dCaNjP6ndLmIqp1MOTGE2Q8hEQ4R1TxPUQkOxYy
	/YvqRMngnNwNSKsfVIgl/Esi6b0h7wzohG4LiR+Y/qxXuaQOoNs8aR0JIbsVRhiPeu0KZbyGN8n
	jAGCfiGSlzK9jNPbC5x1b+v25Wy9nNnQnNtBcXxtp/OlzN3ng0tTkeunknHdeBzqTQQ==
X-Received: by 2002:aca:ed04:: with SMTP id l4mr4209725oih.26.1560456926376;
        Thu, 13 Jun 2019 13:15:26 -0700 (PDT)
X-Received: by 2002:aca:ed04:: with SMTP id l4mr4209698oih.26.1560456925872;
        Thu, 13 Jun 2019 13:15:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560456925; cv=none;
        d=google.com; s=arc-20160816;
        b=rui6XGyeK1j6klt2pcXHHUIX+T62ZFSiC9YurKBThC1z2MixbSxDWe5GMsmSE1hij2
         K/JyYYjDNjMr6x3CbGu6vI7ZyR2MPu+HLSpdsQhMAwiVpnsUAXxficaQIspW5A5EsE5B
         kTRvM3lTZXn0k40iWgznFc+1qsf/NFY4OihtLNuK1u3slWkP51MVDIWdG85zUKfl/WM2
         ydrx+rhmci3YYpVSdxVuEV1CbpqJ5VuR023su/TCGJd70hFDpkl/pYMCPrlA0r3p2lY2
         e56N88+4/h+WrKz04gWGXQp86uIa9xBRdQpdWuaniG+NWH49f8vLGoruUs3tFiFUHtq2
         mLew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gYvi3JENt5xjT7/oQoCCDRRyhuGQKrPeHYLl1e4tUxo=;
        b=UGgCcqmUsDo7ZyLcHhZBrR1WyJjiejnV9CUo6CMJa8ud+RCEK/P8BkZ7xPxOMvSWht
         MoHyThNBf7cjGaFR7l3ahh1It2dQ8RMuwNBRUonSdBpdNDWR0rK/MvFU2K9AGX6YuenN
         slV5r5l76ORto5xlJPu7/9zEpbgBqBBeZRzPmnE1b74H40ufmQRcOB/cwfMiBFZ/TZ2L
         SpxWbA4TQUvLP2FfizT45Vot9vfJXSC30HDtwr1hFKHP056USsgQ/6U1E8eQ1TNkuG3W
         3UbQTgVxOeYR7R5SKaB+CFM4A1ASpyywxx6VrJuu1fiQk+Zc3s0gZIU0CWNQQ3MQXwve
         YXrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=HiQM8Oj8;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t9sor314022oig.169.2019.06.13.13.15.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 13:15:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=HiQM8Oj8;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gYvi3JENt5xjT7/oQoCCDRRyhuGQKrPeHYLl1e4tUxo=;
        b=HiQM8Oj8L+VS1a8Hidw0xr9iYYaQmKDaapqQQLP3xBSAjW2G7zF8GCiMqjGr/ym+Mo
         M+OqlxjvRB4nsYJvbsbx5Z3ifuAo0JozSHiAbNq39t8D2waMsSabG6FDy40WGT4oYy8V
         L96EPmLmkBZ66RnBr04w7xeY6utWIJLm5CrypM9lYrEcqa9F/Z5nPa4IShCeMmTv0t0L
         gS2NRGRi4wYn5eA9ZuBqSXqoz8gXypGTSbll9Wp2Y8UNYHgTyBR1qyLVx2ig9t9lcYmD
         HVaPJZLwJOeNsVJ9c9ozc803Mh/zRF+OxcMsrpFkoEYk0fk+301QRIAXIyrgvI3K0bkW
         VbzA==
X-Google-Smtp-Source: APXvYqyS333Lp+D4vjCDNGXf2txUSus++eUTfldGM7ZmElD6Qov2BJs1+/5zSo9qFUO6PniS7TXRoikGBTwqET2Ahjo=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr4014371oih.73.1560456925540;
 Thu, 13 Jun 2019 13:15:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-9-hch@lst.de>
 <d9e24f8e-986d-e7b8-cf1d-9344ba51719e@deltatee.com>
In-Reply-To: <d9e24f8e-986d-e7b8-cf1d-9344ba51719e@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 13 Jun 2019 13:15:14 -0700
Message-ID: <CAPcyv4gApj=5eYCVSLidDJqF2V1YZiqUht1P26mSzUOjW-ykqA@mail.gmail.com>
Subject: Re: [PATCH 08/22] memremap: pass a struct dev_pagemap to ->kill
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 1:12 PM Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
>
> On 2019-06-13 3:43 a.m., Christoph Hellwig wrote:
> > Passing the actual typed structure leads to more understandable code
> > vs the actual references.
>
> Ha, ok, I originally suggested this to Dan when he introduced the
> callback[1].
>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reported-by: Logan Gunthorpe <logang@deltatee.com> :)


>
> Logan
>
> [1]
> https://lore.kernel.org/lkml/8f0cae82-130f-8a64-cfbd-fda5fd76bb79@deltatee.com/T/#u
>

