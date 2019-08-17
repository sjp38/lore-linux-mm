Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA26CC3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 03:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 856B921743
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 03:35:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="unNNdQ25"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 856B921743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37CCB6B000C; Fri, 16 Aug 2019 23:35:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3063A6B000D; Fri, 16 Aug 2019 23:35:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4AC6B000E; Fri, 16 Aug 2019 23:35:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0006.hostedemail.com [216.40.44.6])
	by kanga.kvack.org (Postfix) with ESMTP id EF0E86B000C
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 23:35:02 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9834D181AC9D3
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:35:02 +0000 (UTC)
X-FDA: 75830503644.25.title74_834a551970c30
X-HE-Tag: title74_834a551970c30
X-Filterd-Recvd-Size: 2816
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:35:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=amkkG0fFLqOV5ST5JcqKziuKz5rtlbB6iQXsDBoiTrs=; b=unNNdQ25SMlyL0bMYg9BMDQyH
	evQOVq5s2u5MkwLkoNQP4Q7lz9gsoSmXrZTvYb66/KdDOwr4W5/vThPxWIP2Ty6m9V2Y5wu6UvAD2
	mFFi0mKg/E4NvzbyVMPHoDVPZo39v1zuZxzFQZYz4bcbl/wnXR7idyqHiO0fTNkn9U9Gi6ZhqDBcY
	N6Z6cTpftFRYL4FbopyTWozBZFGK8z8tn6h0C4ffo4tBs35chF3/CjR1mdSrPAIwnBOzwOlerkbfN
	nALHNGXzeAg6F7BKg2ldDTI+ze7qoWVDr/FKVaHd1v/gAXOwcnm7YJIqniPVi/197MhmSA7ZAMxZW
	0lENUUw9A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hypUI-0002m8-46; Sat, 17 Aug 2019 03:34:42 +0000
Date: Fri, 16 Aug 2019 20:34:42 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Russell King <linux@armlinux.org.uk>,
	Mike Rapoport <rppt@linux.ibm.com>, Rob Herring <robh@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Doug Berger <opendmb@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] arch : arm : add a criteria for pfn_valid
Message-ID: <20190817033441.GD18474@bombadil.infradead.org>
References: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2019 at 11:00:13AM +0800, Zhaoyang Huang wrote:
>  #ifdef CONFIG_HAVE_ARCH_PFN_VALID
>  int pfn_valid(unsigned long pfn)
>  {
> -	return memblock_is_map_memory(__pfn_to_phys(pfn));
> +	return (pfn > max_pfn) ?
> +		false : memblock_is_map_memory(__pfn_to_phys(pfn));
>  }

This is a really awkward way to use the ternary operator.  It's easier to
read if you just:

+	if (pfn > max_pfn)
+		return 0;
 	return memblock_is_map_memory(__pfn_to_phys(pfn));

(if you really wanted to be clever ... er, obscure, you'd've written:

	return (pfn <= max_pfn) && memblock_is_map_memory(__pfn_to_phys(pfn));

... but don't do that)

Also, why is this diverged between arm and arm64?

