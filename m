Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8BB6C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:52:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B18E2190F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:52:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="WsI01r0+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B18E2190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 277988E0013; Wed, 24 Jul 2019 18:52:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 228058E0002; Wed, 24 Jul 2019 18:52:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 117168E0013; Wed, 24 Jul 2019 18:52:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id E47B18E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:52:42 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id h12so26371283otn.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:52:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NS4u+eBseg0DbQA0MU2dSuty1nFLg/yD2ulnxgZWxpw=;
        b=qUwKXyH3euWUf1N7VqokK8vDHuquDUbMc2Yg7bJGczzd7zLEQSDDLztdvUX1aI59AP
         L+RyttPLizGULk+/8eu27JRsJtT5gfwK5P77hTCOIBhA9OJqERvpzm0lVlsXdHDUKK9I
         1QHtXgoJ5M44DyVHIgHNM3Nq+c6YZxEaHWk12QavLj9KF0D7/YtCxF1lVzI8spv3d5d9
         oCRzzBx92Sr9L+Qrce1RiA8sV8gaqjIVqPjZyR3olH8yg5xQkA+PLKCgLeZEftlHkisJ
         cIKBDyH7lsd8N+WH3KgpRo1tb2anF5NeSR3CoLeOVEC/BCltrhjJtm38KG/d9Bh9e4ww
         bK0g==
X-Gm-Message-State: APjAAAVM1Mce4nVor6T32tT5hzUbl2LYVLuLS3rjNbzRcU0/lfvgYN75
	cXY0Cj2y2LDfsKxnR5jfNzfr+7pHwgRXHogg8SYTbgiPtXD5xLh8LjFosjXDcEaqqlfZXeuITJt
	Hbzzjup47BpF0fWr/7XcKb3Uk6erMWceSrhBGNeSlQcOomPmw5YXIT0yymVPAOUuyzQ==
X-Received: by 2002:a9d:5911:: with SMTP id t17mr60571169oth.159.1564008762422;
        Wed, 24 Jul 2019 15:52:42 -0700 (PDT)
X-Received: by 2002:a9d:5911:: with SMTP id t17mr60571143oth.159.1564008761929;
        Wed, 24 Jul 2019 15:52:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564008761; cv=none;
        d=google.com; s=arc-20160816;
        b=JFUo1jVYVJ2SowlgD54bfomos9mf8JOkbFehE4Oa7PRvaHfz+RZ7BRTYoEmQ5XgOlb
         F38NxSIDBwaNcTGwbkgQzuhKTtKqQSbAp/Nr+wEHvVePSFda8K5sTPYCjA3jnJvXFV5/
         y+5D92UkV4OYciw5hy6sJsIjQi8bUFLWNYE2o5Af/xr+o2jCqr8oy3m4+rYf3Z1EaN2Y
         /tHmYgnMw+zrT5BsOFN4vZ3tXRFR2tv4NQz1k0qZFJYjdWn6tIja0aS4IfxI5a3fH7R8
         xJYZnEkRBtRwHvdc5LQaU1qWXTe09Dz9D7/5kLv35F1z2lGQeT3VVfZ/uR6PdnDBM52d
         GzLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NS4u+eBseg0DbQA0MU2dSuty1nFLg/yD2ulnxgZWxpw=;
        b=AzKrp/CitNkMCQuFbNQSl+WDN22/0FYBUGsEyv8vLp7TB0mQZnd4q5CWDEYPkUAHYR
         N6pXqr44QfUrvhgdm8lmxhJw5CCOED2PL+3G67KTVwvuCFnhKt1OZZjOBMP+qksRSeRb
         uQ3CXOYPhKaJlPTd0IQASpEP1fmvne0uDQ2iVkv50jjUiSqh66HD5fAt/aUBPe5boILd
         vq8BdA2U33sSUh+DSMO8subc4Hx6EG3jIb9P2JuHxUq4loahtWJQIqUI88HxHBk6JJdX
         L6A9xW4jhgpOearXSFhf0KFYiEOWU3gWoU8dHTtS1ySE7PhBf+fUbClrZBsIGAbaqSt4
         gAlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=WsI01r0+;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t18sor21117903oij.142.2019.07.24.15.52.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 15:52:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=WsI01r0+;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NS4u+eBseg0DbQA0MU2dSuty1nFLg/yD2ulnxgZWxpw=;
        b=WsI01r0+8S0qHaiUGli9O6VA8G5EbT8wESR+QHOUxt+/JeNKOPhQaHmPMTMh8KeJhi
         knfyeHmKxGpmpur/ltSGLunAHSSg6BCDIPy3rFyWNIOzGn6KeOBjFf0EWl/VovTwjw2Z
         ZF8lTd/ZFvMgkJB+p8yHYfJm6eUvMH5ebX5U6dNhiA2NEsSOM47/uSHe0/CI8vqIrIy5
         nzEgeRtmzAJl4ArzmC9enkYIQ7bvu4mXazcyXaOupfOvh1MFtfCZ8BS9ALKmFxbZDY2/
         mtnlrYGHU8qf5gw0Pziar4dwHIBm8siMjy/LtAfsWqykl6JFTDPIFrc6TJvZvHVV6sf/
         /5fw==
X-Google-Smtp-Source: APXvYqzSZInaKhuMFiPlmjU3dlvlT2OJR7ptIKglkJzXRv3bZsRsA+zEBuvwUDFgRbzKWlufzZxuvok65bNWe4q/BNE=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr40944549oii.0.1564008761619;
 Wed, 24 Jul 2019 15:52:41 -0700 (PDT)
MIME-Version: 1.0
References: <1564007603-9655-1-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1564007603-9655-1-git-send-email-jane.chu@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Jul 2019 15:52:30 -0700
Message-ID: <CAPcyv4iqdbL+=boCciMTgUEn-GU1RQQmBJtNU9RHoV84XNMS+g@mail.gmail.com>
Subject: Re: [PATCH v2 0/1] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS issue
To: Jane Chu <jane.chu@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 3:35 PM Jane Chu <jane.chu@oracle.com> wrote:
>
> Changes in v2:
>  - move 'tk' allocations internal to add_to_kill(), suggested by Dan;

Oh, sorry if it wasn't clear, this should move to its own patch that
only does the cleanup, and then the follow on fix patch becomes
smaller and more straightforward.

