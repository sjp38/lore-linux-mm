Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84061C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:44:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B691222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:44:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B691222D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D94B68E0002; Thu, 14 Feb 2019 12:44:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D426C8E0001; Thu, 14 Feb 2019 12:44:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE5418E0002; Thu, 14 Feb 2019 12:44:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64B198E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:44:53 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id y129so2327684wmd.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:44:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nhONcvXGm61KLi/zYqWGoS2zlMlk8XmKbAq7rlcJi4w=;
        b=buBZp69FxKC4pHdfTdwcD0tuy1J3CHENTCal75Z1dwHWfZspxRb9wz6G02/n2Vb/Y1
         cvgRKVL9Q4P5wqXDXNGmbtC1fTwTcDhZvE4lAud9PHyXm9EJK/uoEmepfBAvjPchzYWA
         OUGjOh9GFDhfzTEjtp05IBBdwjhhvr5h6zoKWPbHO7H56vVnyahDR0JS0C3IUIB60eoo
         Bn7IKiHuAylY8sRBTXp7cqGcVs48aMIU8f9Qd554NGR5DxHh0K7HT3EmGkVYh550MvpF
         TMI1uKxba7mMDhCRT+WeJ19IgCefKfRFW6T6NR7RsRyiqjP+SJjEXpQ3RduUT2ReHU7T
         9mmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAubNG6d8Dv6qmBcATaq4ZIX2IQU0ZTxs/PMtdPpY280AFkRzYooB
	K4TMlsMlrDVVrStmWYnKDY37U4Q6G9F5D+2VEFaPDiIrHqAM6mftKULsnl3W88mOFHV922JSikJ
	HKSjD7T3y//axWfae+uvg6NqDfJAe7x6DnWill1sXBjDjujY7wj1rLQ+NIUV2y8fmng==
X-Received: by 2002:adf:fc87:: with SMTP id g7mr3665150wrr.136.1550166292882;
        Thu, 14 Feb 2019 09:44:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib3pDd6ar8tdBxDSOG0Lu9DsP9MAxqZfFDCYlOOQ6H6sT/vRof8+FiiZpJMrl70Q9Xfs7wT
X-Received: by 2002:adf:fc87:: with SMTP id g7mr3665118wrr.136.1550166292047;
        Thu, 14 Feb 2019 09:44:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550166292; cv=none;
        d=google.com; s=arc-20160816;
        b=Fadjny18ISFIeAP2N9xNOxuEfUT0re1twmrSrjG5asKbVltDaRaRPFDZ7xYyGKr8TK
         b6JYdkCfImALpZnN1DZhVzUEP3vwqXA9rjFDvd6CF5vLvDqeESc3XA06AXqw3iuwO/5N
         z1bvZrUtlxYSiyTfkaHtzzwN7Wf8uWYJSIHvKJo87Amd73TlUaEXbpE/u2mM/nNeCa6z
         /AEf76WGfGQMmoSWEWFhLNtujPzRmnASomh3iChbSOsfs0gGJ2JGqsrX6Csgm9mQhT0D
         pamlTZKj+9+WAOtvn3tPm8p0TyOyw5bP9xBD4fdV3ekDb+pc+dae3AJXjyBNo97nhIlO
         MlOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nhONcvXGm61KLi/zYqWGoS2zlMlk8XmKbAq7rlcJi4w=;
        b=J5aAMTCfm4BBM7X/cocxS89TOLe/lIKwFvNPjj9vCA1SyHF95rRvpsgLw+jcPKqUOV
         696STGS75vbTrTbHH8fCfOjndWT/bsE4YSA2J6ILKrgAzvVtdOrBemvhdgV6EAW0+Z87
         FiCtbKktu5rhMUL2NEdK+arRIGjHRVeiIXGdDwQP2kxVt2C5L6+PGuySPrxoz5Bs4ATQ
         UCaARVvPe64gIEYw5D3uFlUDIUsqlt0aLf9K1Zb0jDJBhex1Ezp0vrDSo4KDqPwJokZL
         4irIhFHwVYIU3dBIqItdBOsB8DHQo3PfVYL88rUKltFFrFyAf13z/m91G64tZaiQ3ZFm
         em7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m1si2274885wmg.171.2019.02.14.09.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:44:52 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 5C65B6FA8C; Thu, 14 Feb 2019 18:44:51 +0100 (CET)
Date: Thu, 14 Feb 2019 18:44:51 +0100
From: Christoph Hellwig <hch@lst.de>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, juergh@gmail.com, tycho@tycho.ws,
	jsteckli@amazon.de, ak@linux.intel.com,
	torvalds@linux-foundation.org, liran.alon@oracle.com,
	keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
	catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
	konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, steven.sistare@oracle.com,
	labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
	peterz@infradead.org, kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Tycho Andersen <tycho@docker.com>
Subject: Re: [RFC PATCH v8 04/14] swiotlb: Map the buffer if it was
 unmapped by XPFO
Message-ID: <20190214174451.GA3338@lst.de>
References: <cover.1550088114.git.khalid.aziz@oracle.com> <b595ffb3231dfef3c6b6c896a8e1cba0e838978c.1550088114.git.khalid.aziz@oracle.com> <20190214074747.GA10666@lst.de> <3c75c46c-2a5a-cd75-83d4-f77d96d22f7d@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c75c46c-2a5a-cd75-83d4-f77d96d22f7d@oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 09:56:24AM -0700, Khalid Aziz wrote:
> On 2/14/19 12:47 AM, Christoph Hellwig wrote:
> > On Wed, Feb 13, 2019 at 05:01:27PM -0700, Khalid Aziz wrote:
> >> +++ b/kernel/dma/swiotlb.c
> >> @@ -396,8 +396,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
> >>  {
> >>  	unsigned long pfn = PFN_DOWN(orig_addr);
> >>  	unsigned char *vaddr = phys_to_virt(tlb_addr);
> >> +	struct page *page = pfn_to_page(pfn);
> >>  
> >> -	if (PageHighMem(pfn_to_page(pfn))) {
> >> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
> > 
> > I think this just wants a page_unmapped or similar helper instead of
> > needing the xpfo_page_is_unmapped check.  We actually have quite
> > a few similar construct in the arch dma mapping code for architectures
> > that require cache flushing.
> 
> As I am not the original author of this patch, I am interpreting the
> original intent. I think xpfo_page_is_unmapped() was added to account
> for kernel build without CONFIG_XPFO. xpfo_page_is_unmapped() has an
> alternate definition to return false if CONFIG_XPFO is not defined.
> xpfo_is_unmapped() is cleaned up further in patch 11 ("xpfo, mm: remove
> dependency on CONFIG_PAGE_EXTENSION") to a one-liner "return
> PageXpfoUnmapped(page);". xpfo_is_unmapped() can be eliminated entirely
> by adding an else clause to the following code added by that patch:

The point I'm making it that just about every PageHighMem() check
before code that does a kmap* later needs to account for xpfo as well.

So instead of opencoding the above, be that using xpfo_page_is_unmapped
or PageXpfoUnmapped, we really need one self-describing helper that
checks if a page is unmapped for any reason and needs a kmap to access
it.

