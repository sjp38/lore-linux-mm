Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D71D3C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 11:31:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87A4720821
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 11:31:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lXaU2h/Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87A4720821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334218E0081; Tue,  5 Feb 2019 06:31:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E1668E001C; Tue,  5 Feb 2019 06:31:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F8928E0081; Tue,  5 Feb 2019 06:31:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0D8F8E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 06:31:55 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e68so2241880plb.3
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 03:31:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=46wwDVY6md2iRiG6auVyzKi3knUFHNtDdo8/Lph88jg=;
        b=qcaBoWJQCv4x4NCIjc0mxZyr9Hv/WX0vdS+fo5M5Wnvieaj4AUpelAnAfj7wLqWZL8
         /TJiiUhyDRPSGhayi1n3Rl6Wj+5Yjss1xO47tBEPvdiHx0B+520kPGn2MDoykI1/Nnut
         t2ldAOFAsL5x6QvJD3Wd31Qt6Mt+BmNMNjkW49Ireyjm1M0hYIXzMBnmTHCqQs/PW6UY
         SKI+U1qxfc/kkvA10gszFCtQrfyWTEArJep90GipP8XFG9AkvrWNOQiGDKUfAVfOMs5V
         eF/KEZvu6DgU733bOZq9T8rq7bPN7Iy7AR0ksW8F272yAfd+N9BAjWtRguhoq/2/c1aJ
         rAdg==
X-Gm-Message-State: AHQUAuYZiukyuoak68GZdOFn0zkvQwXnwEhNd6QUCH6ztF63NUJdfLe5
	22OxR9aK0IDJfIyovwRJBldNQpMLrnt+GuTNH+IRupouROTP3Qqd+Ja8XRIPMRaPO3rxQhC+kBP
	Rk56JC4QK+0yHtx9ly4XYgflvR6HGcVtsY+ERvMZmUSL3iwEjzyvHpXeqTvdI4rHLig==
X-Received: by 2002:a17:902:887:: with SMTP id 7mr4630096pll.164.1549366315378;
        Tue, 05 Feb 2019 03:31:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib3MBUmx9TGaQIiE28WQ7+60VC+NM7N8FfOp8SLA3NS2OCr7gT5b/Xct6ut5VvEab2DxeeJ
X-Received: by 2002:a17:902:887:: with SMTP id 7mr4630026pll.164.1549366314608;
        Tue, 05 Feb 2019 03:31:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549366314; cv=none;
        d=google.com; s=arc-20160816;
        b=ofc035MVUEkknoYE7ofIF7+OCF3Rc4ityJ4dIccxdB+qQNmuaQsGtBUXL/sajJQ3KD
         7i6Jpy6q65GKhLscu5A+CRe1esxhv1XF8r6MPyGYb22YvrruTDIljSJi1SPCUOUhA46V
         RiSbj2iy4L1OexIpxUG9sIT2B7rwclssFTCd1IkLUBfkwbRiTRC/lvIoql0GSt80EYJp
         C8CuhpOY0xZTkN599r480rJfACK1hECKrzWCo9regXEtxJkREppLqDoC3TiaQuP5PZX3
         MYuA8kS5DVfmic/g1YQMCVrk5XORlcYMTtI0qVZ0TQYUlSVErLYIhJ76R8yXljhV7Snb
         +VxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=46wwDVY6md2iRiG6auVyzKi3knUFHNtDdo8/Lph88jg=;
        b=Ww8+3mgf0nm1TedZVFOdN8J+1t6+07YNbqpDziy43Okp1PI7M7jjSyuxPyxS2qDI1E
         RBBGojH8ThwQlUWOpoZBmnP3uMJkYHOtn1ug4yMukyl0fCXOoaIpN3uQXWR5yVGTdOAk
         cYQRoennEb7QHjUhhvDXXWU7mQ4BEYQpNYmmZk4Fw9567mpb7Y3hEE8P9pT5BJYKlTUs
         3ZNlM2nluV/3IfVZ8F7Yym4q78fjNVr/G/dPP5QUX8ok352iqxDFaN42bNq7ggAFt2E1
         wpj7v+pkgQVSSP6hIFZTM+W2JIbQSp5blh7ofBJgh7V1JB8zMSNdlypJ2I6QiovnXsmt
         KkVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="lXaU2h/Z";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id cv19si3372044plb.165.2019.02.05.03.31.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Feb 2019 03:31:54 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="lXaU2h/Z";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=46wwDVY6md2iRiG6auVyzKi3knUFHNtDdo8/Lph88jg=; b=lXaU2h/ZxqCOcjid8EiGGYSFO
	mY9Jts3n21eUwCTh3IeuoIyk0A4JcZRkgViDqDk3egh4n+rtfxDDmHQvMrD5vU+ADZa2V5iKBvcCq
	CrgYq375TC7S6rmOqjOOTmRhmy4BcEzDyogZc91mgNYfCm+ynlHibBKRiPl0vH4FVqXyS2ZUBZ0MS
	5nyjnG3mDfJjS7OrRX4UdMuQMhPqsliJkKq0A0F9JZgL6rXkfv8dLz2f1Yqe7WkRlnPLbWv7F9MrD
	ZcTPGlskaBftD3lFVUQJlyIUHZjafsmSbpBJAg1jQ/AePjXpMJQXQbBb4lKTlFdNzUXwQIk0m3iXR
	VZAKjLDMA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gqyx9-0001qD-OT; Tue, 05 Feb 2019 11:31:47 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 19EFD2029F1D6; Tue,  5 Feb 2019 12:31:46 +0100 (CET)
Date: Tue, 5 Feb 2019 12:31:46 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 06/20] x86/alternative: use temporary mm for text
 poking
Message-ID: <20190205113146.GP17528@hirez.programming.kicks-ass.net>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-7-rick.p.edgecombe@intel.com>
 <20190205095853.GJ21801@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205095853.GJ21801@zn.tnic>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 10:58:53AM +0100, Borislav Petkov wrote:
> > @@ -683,41 +684,102 @@ __ro_after_init unsigned long poking_addr;
> >  
> >  static void *__text_poke(void *addr, const void *opcode, size_t len)
> >  {
> > +	bool cross_page_boundary = offset_in_page(addr) + len > PAGE_SIZE;
> > +	temporary_mm_state_t prev;
> > +	struct page *pages[2] = {NULL};
> >  	unsigned long flags;
> > -	char *vaddr;
> > -	struct page *pages[2];
> > -	int i;
> > +	pte_t pte, *ptep;
> > +	spinlock_t *ptl;
> > +	pgprot_t prot;
> >  
> >  	/*
> > -	 * While boot memory allocator is runnig we cannot use struct
> > -	 * pages as they are not yet initialized.
> > +	 * While boot memory allocator is running we cannot use struct pages as
> > +	 * they are not yet initialized.
> >  	 */
> >  	BUG_ON(!after_bootmem);
> >  
> >  	if (!core_kernel_text((unsigned long)addr)) {
> >  		pages[0] = vmalloc_to_page(addr);
> > -		pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
> > +		if (cross_page_boundary)
> > +			pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
> >  	} else {
> >  		pages[0] = virt_to_page(addr);
> >  		WARN_ON(!PageReserved(pages[0]));
> > -		pages[1] = virt_to_page(addr + PAGE_SIZE);
> > +		if (cross_page_boundary)
> > +			pages[1] = virt_to_page(addr + PAGE_SIZE);
> >  	}
> > -	BUG_ON(!pages[0]);
> > +	BUG_ON(!pages[0] || (cross_page_boundary && !pages[1]));
> 
> checkpatch fires a lot for this patchset and I think we should tone down
> the BUG_ON() use.

I've been pushing for BUG_ON() in this patch set; sod checkpatch.

Maybe not this BUG_ON in particular, but a number of them introduced
here are really situations where we can't do anything sane.

This BUG_ON() in particular is the choice between corrupted text or an
instantly dead machine; what would you do?

In general, text_poke() cannot fail:

 - suppose changing a single jump label requires poking multiple sites
   (not uncommon), we fail halfway through and then have to undo the
   first pokes, but those pokes fail again.

 - this then leaves us no way forward and no way back, we've got
   inconsistent text state -> FAIL.

So even an 'early' fail (like here) doesn't work in the rollback
scenario if you combine them.

So while in general I agree with BUG_ON() being undesirable, I think
liberal sprinking in text_poke() is fine; you really _REALLY_ want this
to work or fail loudly. Text corruption is just painful.

