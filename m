Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2E22C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 07:15:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 658582064A
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 07:15:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HTz9MlS4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 658582064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E39EE6B0005; Tue, 13 Aug 2019 03:15:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEAB86B0006; Tue, 13 Aug 2019 03:15:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFFB46B0007; Tue, 13 Aug 2019 03:15:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id A9C096B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 03:15:28 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 356F4181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:15:28 +0000 (UTC)
X-FDA: 75816543936.03.wing23_4cc90d7eb1b28
X-HE-Tag: wing23_4cc90d7eb1b28
X-Filterd-Recvd-Size: 2638
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:15:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=jQna6PHWwWISAI9eb8f5G01BTeDr0I8GheF/Eo+K8/4=; b=HTz9MlS4eT3VMZpcmwT6alFCT
	S6B+sPeURhnzdT9gdQ2qIknGRKVyc/vsAj6GbVui1feiDmVg14oV98/JNtlY3dGFHQFgEveSbbPyk
	fiIGYRHR2LKIbcaFpaGFPQ8EKmT4SB1Ikwu7wsAsmT5AdJ7pQ+C0RlGw0qyYkV5idobgwoDbkhBVe
	fBDwYp4oRybHYt2FONwYns16my6WWKgzNMl84Y5XoYfQLndRLj2YuLwdoJvJ2/TklCRJ0HtNwJNHx
	L3TH5r0zJyFMOBHlg27ISoAnCWMHUIJ/ptWCvMKJnU0f97Lr3AkWHOmZxotA7D+MqKypBxzt9SeLg
	MBj1hvlUQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hxR1c-0002g8-RL; Tue, 13 Aug 2019 07:15:20 +0000
Date: Tue, 13 Aug 2019 00:15:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Nathan Huckleberry <nhuck@google.com>
Cc: yamada.masahiro@socionext.com, michal.lkml@markovi.net,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, clang-built-linux@googlegroups.com
Subject: Re: [PATCH] kbuild: Change fallthrough comments to attributes
Message-ID: <20190813071520.GA5075@infradead.org>
References: <20190812214711.83710-1-nhuck@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812214711.83710-1-nhuck@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 02:47:11PM -0700, Nathan Huckleberry wrote:
> Clang does not support the use of comments to label
> intentional fallthrough. This patch replaces some uses
> of comments to attributesto cut down a significant number
> of warnings on clang (from ~50000 to ~200). Only comments
> in commonly used header files have been replaced.
> 
> Since there is still quite a bit of noise, this
> patch moves -Wimplicit-fallthrough to
> Makefile.extrawarn if you are compiling with
> clang.

That __attribute__ crap looks like a cat barfed over the keyboard.

Please fix up clang and keep the kernel source sane.


