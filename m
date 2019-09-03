Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E3EBC3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 02:33:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC3C022CF7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 02:33:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Q+3TdsCJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC3C022CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5588E6B0003; Mon,  2 Sep 2019 22:33:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 507586B0005; Mon,  2 Sep 2019 22:33:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41D696B0006; Mon,  2 Sep 2019 22:33:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0019.hostedemail.com [216.40.44.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2184E6B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 22:33:21 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C168D180AD7C3
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 02:33:20 +0000 (UTC)
X-FDA: 75892037760.06.show41_fcb5985556
X-HE-Tag: show41_fcb5985556
X-Filterd-Recvd-Size: 2428
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 02:33:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=f5MyooAk+S2jx9Azz8tQRtMqjUmRVMhWsD0p8g2NXwE=; b=Q+3TdsCJITa2UAiT4ZM35t/W9
	+izgZjYryue23D/fSExm0z/Mt8PQEcMhznPy4Wa0tJAthmcg+/rEZGnlD5wLxdzHCwj9BsCjJfRZN
	JuWzx8nut2IOMam3w9pXwIJdAHrGJLkia+NzjnxZRnCj/MKxCQsDp2VbXefaB4N2Fgz+JzWIZasrG
	etHMBovZi0/JCLyGzxsR/4Fc+/ufkF91YLWuxLcPrXe2byyjWK5/98jIJmHS0NHwPV6PHDLpghL+T
	WlCWMz1ckSWUJoRqGR1S2oEJQ+UC8r39l4gVPkMN8s8rlWG4xrn5VKD/iBsex0IFWC8wh2zhVMR3C
	uI8kaThcA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i4yd9-0005gp-OL; Tue, 03 Sep 2019 02:33:15 +0000
Date: Mon, 2 Sep 2019 19:33:15 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Sebastian Fricke <sebastian.fricke-linux@gmx.de>
Cc: linux-mm@kvack.org
Subject: Re: the linux-mm projects were last updated end of 2017
Message-ID: <20190903023315.GA29434@bombadil.infradead.org>
References: <95e4f329-7634-4d32-5252-1dcb25410201@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <95e4f329-7634-4d32-5252-1dcb25410201@gmx.de>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 07:55:05PM +0200, Sebastian Fricke wrote:
> Hello,
> 
> Is there a current list of active projects flying around?
> 
> I would love to see what is currently in development to look at
> different routes that the mm subsystem is taking.
> 
> But the kernel newbies and the linux-mm site seem to be outdated, could
> anyone point me to a more up-to-date source of information? I would be
> willing to update the current project site of linux-mm, if that is possible.

Probably your best bet is the LSFMM 2019 schedule:

https://docs.google.com/spreadsheets/d/1Z1pDL-XeUT1ZwMWrBL8T8q3vtSqZpLPgF3Bzu_jejfk

You can also read the LSFMM2019 writeups on lwn.net.

