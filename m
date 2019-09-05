Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BE4FC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6F3020693
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:21:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6F3020693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 808B96B0285; Thu,  5 Sep 2019 13:21:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B9EA6B0287; Thu,  5 Sep 2019 13:21:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CDAC6B0288; Thu,  5 Sep 2019 13:21:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0143.hostedemail.com [216.40.44.143])
	by kanga.kvack.org (Postfix) with ESMTP id 474DE6B0285
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:21:34 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D89A0181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:21:33 +0000 (UTC)
X-FDA: 75901533666.29.self18_d9e5d90ba855
X-HE-Tag: self18_d9e5d90ba855
X-Filterd-Recvd-Size: 2106
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:21:33 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7537A337;
	Thu,  5 Sep 2019 10:21:32 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1EFA83F718;
	Thu,  5 Sep 2019 10:21:30 -0700 (PDT)
Date: Thu, 5 Sep 2019 18:21:28 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: hch@lst.de, wahrenst@gmx.net, marc.zyngier@arm.com, robh+dt@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	Paul Walmsley <paul.walmsley@sifive.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>, f.fainelli@gmail.com,
	will@kernel.org, robin.murphy@arm.com, linux-kernel@vger.kernel.org,
	mbrugger@suse.com, linux-rpi-kernel@lists.infradead.org,
	phill@raspberrypi.org, m.szyprowski@samsung.com
Subject: Re: [PATCH v3 4/4] mm: refresh ZONE_DMA and ZONE_DMA32 comments in
 'enum zone_type'
Message-ID: <20190905172126.GG31268@arrakis.emea.arm.com>
References: <20190902141043.27210-1-nsaenzjulienne@suse.de>
 <20190902141043.27210-5-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902141043.27210-5-nsaenzjulienne@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 04:10:42PM +0200, Nicolas Saenz Julienne wrote:
> These zones usage has evolved with time and the comments were outdated.
> This joins both ZONE_DMA and ZONE_DMA32 explanation and gives up to date
> examples on how they are used on different architectures.
> 
> Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

