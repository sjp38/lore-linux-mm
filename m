Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6B86C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 18:42:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68BE72168B
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 18:42:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="quJ2pVLP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68BE72168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E42C26B0005; Tue,  3 Sep 2019 14:42:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF2876B0006; Tue,  3 Sep 2019 14:42:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D09636B0007; Tue,  3 Sep 2019 14:42:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0246.hostedemail.com [216.40.44.246])
	by kanga.kvack.org (Postfix) with ESMTP id AE8AA6B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:42:40 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 41E63180AD7C3
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 18:42:40 +0000 (UTC)
X-FDA: 75894480480.18.pain98_173c5e315824a
X-HE-Tag: pain98_173c5e315824a
X-Filterd-Recvd-Size: 3958
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 18:42:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ff7ZjFTOqxV3xkKHTbcWbX4Ce4wUnE9dBUFdZUQ37V4=; b=quJ2pVLPS+No92+hE47wZ1XPz
	/wKQF03deSUUj16+jHG1JEKDS/vTG9jxGVRrb1QFqs/qMqBU2ImCUi9Y3WcgR0BGg/RinfVJUe24A
	0rfA+y8Pkeq3/KVyEYipQ6euZnHBmwBTCJcoeueVZDhzDaRNGEInkbX4+Urhqik8TpEwziy9nIi7P
	3czssdOoASHba268O0uqG6Pfy4BPKswc+t3je2S5RpMDpB9nUqMbYtOBiNJKV96PCIsbysQMuGQlW
	7uQdIjx1uoY9i04u85L3wdr3VeZ2F1fCBkz0XFWm04KvYuNjYope64wP/7P/ozGUPiXJVrDeqPvgx
	Q8DMMaesA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5Dl8-00025P-KW; Tue, 03 Sep 2019 18:42:30 +0000
Date: Tue, 3 Sep 2019 11:42:30 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: linux-mm@kvack.org
Subject: Re: How to use huge pages in drivers?
Message-ID: <20190903184230.GJ29434@bombadil.infradead.org>
References: <20190903182627.GA6079@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903182627.GA6079@nautica>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 08:26:27PM +0200, Dominique Martinet wrote:
> Some context first. I'm inquiring in the context of mckernel[1], a
> lightweight kernel that works next to linux (basically offlines a
> few/most cores, reserve some memory and have boot a second OS on that to
> run HPC applications).
> Being brutally honest here, this is mostly research and anyone here
> looking into it will probably scream, but I might as well try not to add
> too many more reasons to do so....
> 
> One of the mecanisms here is that sometimes we want to access the
> mckernel memory from linux (either from the process that spawned the
> mckernel side process or from a driver in linux), and to do that we have
> mapped the mckernel side virtual memory range to that process so it can
> page fault.
> The (horrible) function doing that can be found here[2], rus_vm_fault -
> sends a message to the other side to identify the physical address
> corresponding from what we had reserved earlier and map it quite
> manually.
> 
> We could know at this point if it had been a huge page (very likely) or
> not; I'm observing a huge difference of performance with some
> interconnect if I add a huge kludge emulating huge pages here (directly
> manipulating the process' page table) so I'd very much like to use huge
> pages when we know a huge page has been mapped on the other side.
> 
> 
> 
> What I'd like to know is:
>  - we know (assuming the other side isn't too bugged, but if it is we're
> fucked up anyway) exactly what huge-page-sized physical memory range has
> been mapped on the other side, is there a way to manually gather the
> pages corresponding and merge them into a huge page?

You're using the word 'page' here, but I suspect what you really mean is
"pfn" or "pte".  As you've described it, it doesn't matter what data structure
Linux is using for the memory, since Linux doesn't know about the memory.

We have vmf_insert_pfn_pmd() which is designed to be called from your
->huge_fault handler.  See dev_dax_huge_fault() -> __dev_dax_pmd_fault()
for an example.  It's a fairly new mechanism, so I don't think it's
popular with device drivers yet.

All you really need is the physical address of the memory to make this work.

