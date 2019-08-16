Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 452C8C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:41:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ACCE2133F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:41:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Y1tPwsGX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ACCE2133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD4446B0005; Fri, 16 Aug 2019 02:41:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A84126B0006; Fri, 16 Aug 2019 02:41:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 999DA6B0007; Fri, 16 Aug 2019 02:41:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0009.hostedemail.com [216.40.44.9])
	by kanga.kvack.org (Postfix) with ESMTP id 727D66B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:41:25 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CA5B1180AD806
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:41:24 +0000 (UTC)
X-FDA: 75827344488.24.pull90_639b190d0db40
X-HE-Tag: pull90_639b190d0db40
X-Filterd-Recvd-Size: 2368
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:41:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/3AMdneQMHbJ6jzTXFd3V+Aivs0XGBJ9bktDdp3GzLQ=; b=Y1tPwsGXD3zLqx6AOMMUC3Ugj
	xvuB4D2C6bk0bsDZUc2vCFCGWjhFXIVzYgysQXCcQRB+uikJ0X/l2H1E1y5QD8FXqA88WZOUhmp8R
	U6kV5i27Z4lDw2/Sm9wfTyEATaiZTF3TiyVuQZ3IxRvey7pa7QuyHbhRCJsjIMC02NAylFSATtg/P
	Liz4EatPY+I/G/jvRno3m2IaEvVXSFDadd4wOM63qLJOvYGraOJEbkkulmEVq6vQ2YLLFGss0Rjnp
	8oi7Fbs95eCMQPUOgvBZ4KT9i8SXNpRGURLuo5Csu6hmKkNjXlqBU0/I8zcD2FkEjXhudVjYt8BSL
	oAd7Pn+9A==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hyVvN-0003KH-5j; Fri, 16 Aug 2019 06:41:21 +0000
Date: Thu, 15 Aug 2019 23:41:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: hch@infradead.org, akpm@linux-foundation.org, tytso@mit.edu,
	viro@zeniv.linux.org.uk, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 2/2] vfs: don't allow writes to swap files
Message-ID: <20190816064121.GB2024@infradead.org>
References: <156588514105.111054.13645634739408399209.stgit@magnolia>
 <156588515613.111054.13578448017133006248.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156588515613.111054.13578448017133006248.stgit@magnolia>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The new checks look fine to me, but where does the inode_drain_writes()
function come from, I can't find that in my tree anywhere.

Also what does inode_drain_writes do about existing shared writable
mapping?  Do we even care about that corner case?

