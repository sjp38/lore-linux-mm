Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47899C3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 08:39:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07C3320B7C
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 08:39:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uQpjyXdj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07C3320B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78BC86B0008; Sun, 18 Aug 2019 04:39:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7141F6B000A; Sun, 18 Aug 2019 04:39:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 602B16B000C; Sun, 18 Aug 2019 04:39:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0051.hostedemail.com [216.40.44.51])
	by kanga.kvack.org (Postfix) with ESMTP id 395E56B0008
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 04:39:46 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E49B6181AC9B4
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 08:39:45 +0000 (UTC)
X-FDA: 75834900330.06.fact93_552c72a872727
X-HE-Tag: fact93_552c72a872727
X-Filterd-Recvd-Size: 2566
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 08:39:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=A8d2I2K56+XviRcc09JFeUkjqbtGOWdxc/knibMVkIU=; b=uQpjyXdjSpz/Hwt2agEx42kAf
	g+mz/QcKcO6V1V4Xtq3cYXDNbU+ahexhe6g4YACs/+mbI1t36oXkGrXyP5sfu8d401R4N0lbT7mZ3
	imAzQ31GommzEmy+3D/q7XEthqyrOBZv/QZxlltY/D60997ot3RhVFCaXTqpDos9//n8D5KLAubry
	mTO/hAB+WtGqCNfdFaXxeRoIUC3/3JrLsSWAMwxYDxy0R8PHGtlvKuxwedTsclaxY7pbRm5nBkN/J
	x5vdCXJ0L5ycFl9dJ1RbbfRUB7sbiD2Mh9Q8WnyTvIQvtA/EwNYHv3+l0uiJs0B6j91pFSdNlsOuB
	tTlE+niug==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hzGiv-0003cZ-6g; Sun, 18 Aug 2019 08:39:37 +0000
Date: Sun, 18 Aug 2019 01:39:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: hch@infradead.org, akpm@linux-foundation.org, tytso@mit.edu,
	viro@zeniv.linux.org.uk, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 2/2] vfs: don't allow writes to swap files
Message-ID: <20190818083937.GC13583@infradead.org>
References: <156588514105.111054.13645634739408399209.stgit@magnolia>
 <156588515613.111054.13578448017133006248.stgit@magnolia>
 <20190816161948.GJ15186@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816161948.GJ15186@magnolia>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 09:19:49AM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Don't let userspace write to an active swap file because the kernel
> effectively has a long term lease on the storage and things could get
> seriously corrupted if we let this happen.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

