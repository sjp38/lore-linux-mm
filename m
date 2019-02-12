Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50C4BC4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:25:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16FF520863
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:25:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16FF520863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FE058E0005; Tue, 12 Feb 2019 10:25:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D38B8E0001; Tue, 12 Feb 2019 10:25:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C2888E0005; Tue, 12 Feb 2019 10:25:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2771F8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:25:47 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id b8so1127311wru.10
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:25:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yLr3B6EjkZmF0GZX3m8gHAssJj7WssqkIwnmoWU6nC0=;
        b=I2ppX0U+UaUddDSxqDkOaZjPovwHYmwPcdh3mfftbK4ZUbfCUCXTMkC8lts3Va/1gE
         CgclvuUaCT9z/myvtYavuy/jupvuUXxX8G+zM5iGhwNjAXMJwXoOgLo8ygget7fRMut+
         YGGImGBIM31iLpkHhYKKJiP8GLW1HPfNa5cyacbYLZeIGvurYp66H/l8x8C2hBdHiFHO
         q/VSxaJDKTvbukkQMkJfDx0OzSiq9A+2bndJ1ShalYqt9qpmkORVinSx0RiQcLQfv9R/
         SwnXj+xgQT5fQjvkSxVyzMgML53j4NNS6KQQzC/+EDOrJKm7c//Bhq3dopsZabHNFbt8
         1CMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuaA30RuO8/4+WtCfQ5JvsSzr+NYcj8ZgxTIHd5vNPgLnCUrv629
	yvjmxNFhmSz+gVZ/B03pWLQbq67SDyjzHUeGU5NlSLziOUXqAFLKpg6XrCsvLd/aJ7SJvg9gPGM
	wCSEj2A8eCJFczS/8ZkaSFsLZzEUKCIQDgZ62yA2kD8nYMyMEnOYptIWGfoWCKVvuoQ==
X-Received: by 2002:a05:6000:104b:: with SMTP id c11mr3348944wrx.303.1549985146687;
        Tue, 12 Feb 2019 07:25:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZHVAinzylIcfsrsh0rlCk8y0k3P8PCylCwEUFuLH9b13DYA9sWoiXMaxW88Hoj+kzdlIwC
X-Received: by 2002:a05:6000:104b:: with SMTP id c11mr3348888wrx.303.1549985145759;
        Tue, 12 Feb 2019 07:25:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549985145; cv=none;
        d=google.com; s=arc-20160816;
        b=uhyPuwBbgU2j7vByxcJSdaCzSKrKzroL4wvGlZHTgUv7THQm6k5mtDK3bFdwS2FVvI
         szfU0r5Ev9RZpU745Iz+d9DBLKofzM3BSg7yiL5lYjgp0bILWt5QrFszVeX9/m0XwJHT
         pax+ME5Wm1N3U0Nw9sfIqNMZxSdziwb5vREGLF7I/PwFwfF0R8iPYIDDGWfmxz1Iy7PN
         l/kWH7xDsw/SKtBAGvKyf26MIQv9coNqb6GrIFhpcIQ/pqo/A3D38GRnQ0vl6CdqHuWy
         pPyEc4cVfKud8fFk4PcozaZSl6Hr+7IGr07QlCRsLxjDH8Iqsr+sQN4cpTL11YZteCPz
         qSoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yLr3B6EjkZmF0GZX3m8gHAssJj7WssqkIwnmoWU6nC0=;
        b=JehPefdP4otT3fmeKm6b40xXi4oByyhB0gL0hJP0OK5sgH+UmAXjYmYvM30Rai9KVx
         cfwUz6uHHk/qkK2ZnmleLYwfXdeX0B46/kcST/ege775a2OyPmoRNNFipjrcuzL7aJdb
         Js8eZ+chPsWTEvY4dhKU49tJhm87tje3PA6fWOkUTgQu3ks15HwrPUXUg4YDHTqSIJsg
         R+AN5HLe8nxOEA8N+XWvlSoe1vWFj/SJdZwcWGELUQ3p4g+216mtN69h4D+f16X3pTyA
         UGneMPdp2QTYMn8rtQu94oQ9jtPNa7HCzdSZ6redBWLRHaqNrKdGwkw5RQ3LfYvfOgjp
         yvZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s12si9431880wrw.100.2019.02.12.07.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:25:45 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 1358A68DDC; Tue, 12 Feb 2019 16:25:45 +0100 (CET)
Date: Tue, 12 Feb 2019 16:25:45 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190212152543.GA24061@lst.de>
References: <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de> <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de> <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de> <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de> <20190208091818.GA23491@lst.de> <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de> <20190211073804.GA15841@lst.de> <820bfeb1-30c0-3d5a-54a2-c4f9a8c15b0e@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <820bfeb1-30c0-3d5a-54a2-c4f9a8c15b0e@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 01:42:56PM +0100, Christian Zigotzky wrote:
> On 11 February 2019 at 08:38AM, Christoph Hellwig wrote:
>> On Sun, Feb 10, 2019 at 01:00:20PM +0100, Christian Zigotzky wrote:
>>> I tested the whole series today. The kernels boot and the P.A. Semi
>>> Ethernet works! :-) Thanks a lot!
>>>
>>> I also tested it in a virtual e5500 QEMU machine today. Unfortunately the
>>> kernel crashes.
>> This looks like a patch I fixed in mainline a while ago, but which
>> the powerpc tree didn't have yet.
>>
>> I've cherry picked this commit
>> ("swiotlb: clear io_tlb_start and io_tlb_end in swiotlb_exit")
>>
>> and added it to the powerpc-dma.6 tree, please retry with that one.
>>
> Hello Christoph,
>
> Have you added it to the powerpc-dma.6 tree yet? The last commit was 4 days 
> ago.

I added it, but forgot to push it out.  It is there now, sorry:

http://git.infradead.org/users/hch/misc.git/commitdiff/2cf0745b7420af4a3e871d5a970a45662dfae69c

