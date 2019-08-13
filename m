Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 936BDC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:37:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DBF5205F4
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:37:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DBF5205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1757D6B0006; Tue, 13 Aug 2019 11:37:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1265E6B0007; Tue, 13 Aug 2019 11:37:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 063D96B0008; Tue, 13 Aug 2019 11:37:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id DB57C6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:37:12 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 90A72180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:37:12 +0000 (UTC)
X-FDA: 75817808304.04.ball25_5bdd41e1b7113
X-HE-Tag: ball25_5bdd41e1b7113
X-Filterd-Recvd-Size: 1418
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:37:11 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 6FB1368B02; Tue, 13 Aug 2019 17:37:07 +0200 (CEST)
Date: Tue, 13 Aug 2019 17:37:07 +0200
From: "hch@lst.de" <hch@lst.de>
To: Atish Patra <Atish.Patra@wdc.com>
Cc: "hch@lst.de" <hch@lst.de>,
	"paul.walmsley@sifive.com" <paul.walmsley@sifive.com>,
	"palmer@sifive.com" <palmer@sifive.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Damien Le Moal <Damien.LeMoal@wdc.com>,
	"linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 16/17] riscv: clear the instruction cache and all
 registers when booting
Message-ID: <20190813153707.GA8686@lst.de>
References: <20190624054311.30256-1-hch@lst.de> <20190624054311.30256-17-hch@lst.de> <78919862d11f6d56446f8fffd8a1a8c601ea5c32.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <78919862d11f6d56446f8fffd8a1a8c601ea5c32.camel@wdc.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 09:26:18PM +0000, Atish Patra wrote:
> That means it should be done for S-mode as well. Right ?

For S-mode the bootloader/sbi should take care of it.

