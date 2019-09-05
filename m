Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9501C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:05:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76999206DE
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:05:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76999206DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 136F76B0279; Thu,  5 Sep 2019 13:05:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E8156B027C; Thu,  5 Sep 2019 13:05:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3EEE6B027D; Thu,  5 Sep 2019 13:05:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id CE00F6B0279
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:05:31 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 67935443C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:05:31 +0000 (UTC)
X-FDA: 75901493262.16.cause48_12c87c0828243
X-HE-Tag: cause48_12c87c0828243
X-Filterd-Recvd-Size: 1951
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:05:28 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DABAF28;
	Thu,  5 Sep 2019 10:05:27 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D80663F718;
	Thu,  5 Sep 2019 10:05:25 -0700 (PDT)
Date: Thu, 5 Sep 2019 18:05:23 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: hch@lst.de, wahrenst@gmx.net, marc.zyngier@arm.com, robh+dt@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org,
	f.fainelli@gmail.com, will@kernel.org, robin.murphy@arm.com,
	mbrugger@suse.com, linux-rpi-kernel@lists.infradead.org,
	phill@raspberrypi.org, m.szyprowski@samsung.com
Subject: Re: [PATCH v3 1/4] arm64: mm: use arm64_dma_phys_limit instead of
 calling max_zone_dma_phys()
Message-ID: <20190905170523.GD31268@arrakis.emea.arm.com>
References: <20190902141043.27210-1-nsaenzjulienne@suse.de>
 <20190902141043.27210-2-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902141043.27210-2-nsaenzjulienne@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 04:10:39PM +0200, Nicolas Saenz Julienne wrote:
> By the time we call zones_sizes_init() arm64_dma_phys_limit already
> contains the result of max_zone_dma_phys(). We use the variable instead
> of calling the function directly to save some precious cpu time.
> 
> Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

