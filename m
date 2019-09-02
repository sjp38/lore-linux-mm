Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6B78C3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 13:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95A962168B
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 13:01:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95A962168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34ABF6B0007; Mon,  2 Sep 2019 09:01:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FBF16B0008; Mon,  2 Sep 2019 09:01:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 212186B000A; Mon,  2 Sep 2019 09:01:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0193.hostedemail.com [216.40.44.193])
	by kanga.kvack.org (Postfix) with ESMTP id E86476B0007
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:01:08 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6DBD67591
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 13:01:08 +0000 (UTC)
X-FDA: 75889991016.21.water57_26f82f2b2401d
X-HE-Tag: water57_26f82f2b2401d
X-Filterd-Recvd-Size: 2408
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 13:01:07 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 0E88568AFE; Mon,  2 Sep 2019 15:01:02 +0200 (CEST)
Date: Mon, 2 Sep 2019 15:01:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org,
	linux-riscv@lists.infradead.org, will@kernel.org,
	m.szyprowski@samsung.com, linux-arch@vger.kernel.org,
	f.fainelli@gmail.com, frowand.list@gmail.com,
	devicetree@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	marc.zyngier@arm.com, robh+dt@kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, phill@raspberryi.org,
	mbrugger@suse.com, eric@anholt.net, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org, wahrenst@gmx.net,
	akpm@linux-foundation.org, Robin Murphy <robin.murphy@arm.com>
Subject: Re: [PATCH v2 01/11] asm-generic: add dma_zone_size
Message-ID: <20190902130101.GA2051@lst.de>
References: <20190820145821.27214-1-nsaenzjulienne@suse.de> <20190820145821.27214-2-nsaenzjulienne@suse.de> <20190826070939.GD11331@lst.de> <027272c27398b950f207101a2c5dbc07a30a36bc.camel@suse.de> <20190830144536.GJ36992@arrakis.emea.arm.com> <bdeda2206b751a1c6a8d2e0732186792282633c6.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bdeda2206b751a1c6a8d2e0732186792282633c6.camel@suse.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2019 at 07:24:25PM +0200, Nicolas Saenz Julienne wrote:
> I'll be happy to implement it that way. I agree it's a good compromise.
> 
> @Christoph, do you still want the patch where I create 'zone_dma_bits'? With a
> hardcoded ZONE_DMA it's not absolutely necessary. Though I remember you said it
> was a first step towards being able to initialize dma-direct's min_mask in
> meminit.

I do like the variable better than the current #define.  I wonder if
really want a mask or a max_zone_dma_address like variable.  So for this
series feel free to drop the patch.   I'll see if I'll pick it up
later or if we can find some way to automatically propagate that
information from the zone initialization.

