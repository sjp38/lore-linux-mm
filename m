Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6EB5C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 17:50:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E89621670
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 17:50:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hQwnhGyg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E89621670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3D9C6B0003; Wed,  4 Sep 2019 13:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CECE36B0006; Wed,  4 Sep 2019 13:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C02746B0007; Wed,  4 Sep 2019 13:50:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0121.hostedemail.com [216.40.44.121])
	by kanga.kvack.org (Postfix) with ESMTP id A05A26B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:50:39 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4472A87CB
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 17:50:39 +0000 (UTC)
X-FDA: 75897978198.06.leaf28_3fcdee288a35f
X-HE-Tag: leaf28_3fcdee288a35f
X-Filterd-Recvd-Size: 5513
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 17:50:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=CIqD9dcYxtNCrgWQIrMf8L3+LM7O9X+A/lkCmo4M2x0=; b=hQwnhGyg/RQE7bI5c1GIoOCYY
	i8fXusrFw+ZYvagRav4y0tXfBu3TQga+Gth1ihSElm7RH1ROvrEWaT5JCuGlKcMHO8ALAbMn/UWsK
	eSIdyexxKaqxBwa4PQxsqFN4qMd8OT/cq3XFQq0W2L4/xyS58DqCoHkXMz6ugjWftlwSggVOqNXYf
	LjLBluBr7+zheu0hs8XizeW4QqfjgEX/WXitI1d80XTScsVyKCFu84Q+JTToZUiLHcAQfXVUXW9yP
	50+Am7AdNPlF37rTEjRAmYgTwrL9WlTKp9UJjpuIqmOEQfzbT71WKeVetyvVkTb8XKwBiww5xv3LJ
	0iIlTTZCg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5ZQO-0007vf-FW; Wed, 04 Sep 2019 17:50:32 +0000
Date: Wed, 4 Sep 2019 10:50:32 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: linux-mm@kvack.org
Subject: Re: How to use huge pages in drivers?
Message-ID: <20190904175032.GL29434@bombadil.infradead.org>
References: <20190903182627.GA6079@nautica>
 <20190903184230.GJ29434@bombadil.infradead.org>
 <20190903212815.GA7518@nautica>
 <20190904170056.GA9825@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904170056.GA9825@nautica>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 04, 2019 at 07:00:56PM +0200, Dominique Martinet wrote:
> Dominique Martinet wrote on Tue, Sep 03, 2019:
> > Matthew Wilcox wrote on Tue, Sep 03, 2019:
> > > > What I'd like to know is:
> > > >  - we know (assuming the other side isn't too bugged, but if it is we're
> > > > fucked up anyway) exactly what huge-page-sized physical memory range has
> > > > been mapped on the other side, is there a way to manually gather the
> > > > pages corresponding and merge them into a huge page?
> > > 
> > > You're using the word 'page' here, but I suspect what you really mean is
> > > "pfn" or "pte".  As you've described it, it doesn't matter what data structure
> > > Linux is using for the memory, since Linux doesn't know about the memory.
> > 
> > Correct, we're already using vmf_insert_pfn
> 
> Actually let me take that back, vmf_insert_pfn is only used if
> pfn_valid() is false, probably as a safeguard of sort(?).
> The normal case went with pfn_to_page(pfn) + vm_insert_page() so, as
> things stands.
> I do have a few more questions if you could humor me a bit more...
> 
>  - the vma was created with a vm_flags including VM_MIXEDMAP for some
> reason, I don't know why.
> If I change it to VM_PFNMAP (which sounds better here from the little I
> understand of this as we do not need cow and looks a bit simpler?), I
> can remove the vm_insert_page() path and use the vmf_insert_pfn one
> instead, which appears to work fine for simple programs... But the
> kernel thread for my network adapter (bxi... which is not upstream
> either I guess.. sigh..) no longer tries to fault via my custom .fault
> vm operation... Which means I probably did need MIXEDMAP ?

Strange ... PFNMAP absolutely should try to fault via the ->fault
vm operation (although see below)

>  - ignoring that for now (it's not like I need to switch to PFNMAP);
> adding vmf_insert_pfn_pmd() for when the remote side uses large pages,
> it complains that the vmf->pmd is not a pmd_none nor huge nor a devmap
> (this check appears specific to rhel7 kernel, I could temporarily test
> with an upstream kernel but the network adapter won't work there so I'll
> need this to work on this ultimately)
> 
> It looks like handle_mm_fault() will always try to allocate a pmd so it
> should never be empty in my fault handler, and I don't see anything else
> than vmf_insert_pfn_pmd() setting the mkdevmap flag, and it's not huge
> either...
> (on a dump, the the pmd content is 175cb18067, so these flags according
> to crash for x86_64 are (PRESENT|RW|USER|ACCESSED|DIRTY))
> 
> I tried adding a huge_fault vm op thinking it might be called with a
> more appropriate pmd but it doesn't seem to be called at all in my
> case..? I would have assumed from the code that it would try every page

You shouldn't be calling vmf_insert_pfn_pmd() from a regular ->fault
handler, as by then the fault handler has already inserted a PMD.
The ->huge_fault handler is the place to call it from.

You may need to force PMD-alignment for your call to mmap().

> Long story short, I think I have some deeper undestanding problem about
> the whole thing. Do I also need to use some specific flags when that
> special file is mmap'd to allow huge_fault to be called ?
> I think transparent_hugepage_enabled(vma) is fine, but the vmf.pmd found
> in __handle_mm_fault is probably already not none at this point...?
> 
> Thanks again, feel free to ignore me for a bit longer I'll keep digging
> my own grave, writing to a rubber duck that might have an idea of how
> far the wrong way I've gone already helps... :D

Hope these pointers are slightly more useful than a rubber duck ;-)

