Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF5A4C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:07:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B1452086C
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:07:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B1452086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sntech.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282AE8E0003; Thu, 31 Jan 2019 07:07:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2307B8E0001; Thu, 31 Jan 2019 07:07:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12CF88E0003; Thu, 31 Jan 2019 07:07:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id C55338E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:07:17 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id e1so889984wmg.0
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:07:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I/+I8Hs4XSOK/FY9wwskcFVCVmsHYmG++FsbuDrxM5k=;
        b=NassXhAXabJuMeiQ6LXUYLLfKQzh6F1xp9vk2uVAJnK5Nh6+8cfINcmc+i+ErxO6Qy
         Hr+uQ8i7+xVMjEl6R5M0z1k/wJZu6VSwXkzN9Di9LUZfTOKL5iKRa8QJUT/Joo5USv+1
         Bu/UNqZPyhwkGlaOm9zT7iRY7aaxZo9BBFLE4NJ9kgPflksOIdHHbxLNpm9JiwYkTW/r
         1FHbA2fznnUR4itvs7nBMfDAvlIx/2xLMi01R9lBaA0V3gGSCNaDR+hPlATglKU8+A1N
         l9bBkIR9O49qdtIC2DjWZE/MkzRXpDOOsgS2OlQPICaNsb3wu95Vkd1mFKADNV65PsDA
         uhWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
X-Gm-Message-State: AJcUukeI86YGG8Cfc/g7QzOndU6AoywfAb89ouXZbz2gJDVa5fWA3XCL
	/gvaAVLZ1kvYLrdeUCLDfnQTECZBwzgwvgWrb9/13eImnWLHEaxV9LOwHJxl20loetywCzC1ugl
	il8fSigmhUNfYJkfKip1EOg3zNJF5t7N6reI2yTOIzOdZPc4VIVOpVHjt/fxM0kcr7Q==
X-Received: by 2002:a1c:5dd1:: with SMTP id r200mr30329699wmb.93.1548936437227;
        Thu, 31 Jan 2019 04:07:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN56M/q3LpNUIqaYQRwHWSkAdJPZS1HBRA4lA2t/6Ue6c95ccvDPv2uwy29iGv866DmbITbT
X-Received: by 2002:a1c:5dd1:: with SMTP id r200mr30329632wmb.93.1548936436413;
        Thu, 31 Jan 2019 04:07:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548936436; cv=none;
        d=google.com; s=arc-20160816;
        b=R/VZ2PEUp4kHbnff+6W1/YZD8YShqOW4bmGxYt/EavI+nnejhPrAvFLieTaAhS0H45
         ENfXlVNNZlB0FskivxBEB2OmiEosNhijawQ/sWVg0HJYQcGTY7WYuxJS83xt5asBUvlI
         Bg/t8HSVPl1msb0I5PcEqTUjMmCFZbyEiW0yhdNeMV8o0/BYFxmsT8Hl7u5jIujy8ToE
         Es7yH7VMMxTKeid2qjicY8eWMOcZklyyxizgH/ho0CSPL8x/jHH4h8kdb42/iHdejn9p
         VPc1uKM456GGJeN1igPiVG1laIF2slPrD8uMGpfzM8F1uk62rRAEbGqT5JIM2WQwJZuJ
         QEpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=I/+I8Hs4XSOK/FY9wwskcFVCVmsHYmG++FsbuDrxM5k=;
        b=v7bJcUG3p0UgYQspDXt4gkOjv1zp0U9ruACudZOeMWhSXj+1wapa9ubeFrVU8OtQfT
         7YT7FumzENTt/fAfFS2ktMN8kFc/lz5pKmvxVm9elAQVa0RNjd1+/065KKcpxhZrYIsY
         Ue+89lhZyObM9YUwJF149iErRLvB3iVARQ8VnCuu7rMbaHk8FOVN7EhPJwMEnGSJpoaK
         Zie4VzR5bZ2oUPoW1vvQW64ZwvBkrLuD1hcCypBm7rCb51uxo+dMJo7tndpSokkTIogU
         d4R61luLsh4epS3hLMC+yjE2I+MZVwRrnqFI2IWtMyDgSULDg3JZs+13nqCmBn3Q1L0E
         Yjyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
Received: from gloria.sntech.de (gloria.sntech.de. [185.11.138.130])
        by mx.google.com with ESMTPS id z2si3542176wmb.141.2019.01.31.04.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 04:07:16 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) client-ip=185.11.138.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
Received: from wf0848.dip.tu-dresden.de ([141.76.183.80] helo=phil.localnet)
	by gloria.sntech.de with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.89)
	(envelope-from <heiko@sntech.de>)
	id 1gpB7W-0003tR-GB; Thu, 31 Jan 2019 13:07:02 +0100
From: Heiko Stuebner <heiko@sntech.de>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, hjc@rock-chips.com, airlied@linux.ie, linux@armlinux.org.uk, robin.murphy@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org
Subject: Re: [PATCHv2 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
Date: Thu, 31 Jan 2019 13:07:05 +0100
Message-ID: <8111278.aDhVmSDgJm@phil>
In-Reply-To: <20190131031040.GA2320@jordon-HP-15-Notebook-PC>
References: <20190131031040.GA2320@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am Donnerstag, 31. Januar 2019, 04:10:40 CET schrieb Souptick Joarder:
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

hmm, I'm missing a changelog here between v1 and v2.
Nevertheless I managed to test v1 on Rockchip hardware
and display is still working, including talking to Lima via prime.

So if there aren't any big changes for v2, on Rockchip
Tested-by: Heiko Stuebner <heiko@sntech.de>

Heiko


