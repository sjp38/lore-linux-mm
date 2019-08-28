Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0D8EC3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:47:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADB222077B
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:47:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADB222077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612966B0006; Wed, 28 Aug 2019 10:47:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3EF6B0008; Wed, 28 Aug 2019 10:47:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DA886B000C; Wed, 28 Aug 2019 10:47:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB626B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:47:33 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DE925180AD7C3
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:47:32 +0000 (UTC)
X-FDA: 75872115144.15.cave19_5eefff93f8e12
X-HE-Tag: cave19_5eefff93f8e12
X-Filterd-Recvd-Size: 1287
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:47:32 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id BA2F368B05; Wed, 28 Aug 2019 16:47:28 +0200 (CEST)
Date: Wed, 28 Aug 2019 16:47:28 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"daniel@ffwll.ch" <daniel@ffwll.ch>
Subject: Re: [PATCH] mm: remove the
 __mmu_notifier_invalidate_range_start/end exports
Message-ID: <20190828144728.GA30428@lst.de>
References: <20190828142109.29012-1-hch@lst.de> <20190828144020.GI914@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190828144020.GI914@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 02:40:25PM +0000, Jason Gunthorpe wrote:
> EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
> 
> elixir suggest this is not called outside mm/ either?

Yes, it seems like that one should go away as well.

