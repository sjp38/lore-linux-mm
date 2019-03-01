Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4F1DC10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:44:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BE9720842
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:44:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gZsx/MRd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BE9720842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA2208E0003; Fri,  1 Mar 2019 16:44:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FEAF8E0001; Fri,  1 Mar 2019 16:44:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A1F48E0003; Fri,  1 Mar 2019 16:44:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 482F58E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 16:44:13 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id s22so18635789plq.7
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 13:44:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=I9/CQcAMDAqcYCsl2DT89h8s6NYBhCyEInQQWC9dKTs=;
        b=rBk9lZaNXI18nFTpLapTzaiI8jpah4xwWLxd5cMgQsRdXRQSuMjALeIIqoqEE0k222
         zjKxC4I8zeuOdVLid4aU0oNQTH3vQtY+NjIQr/ateg7ycSI0++nlolt7+IHXld63h7EE
         gi95kVjc/5ifR9o/yPcFCf/1e+9+MPubef6YTNakoBdt6Dh5DBTs69hUIawJF/chWobM
         dWViWdnXr168LjRyE/YfqK8qr7tfo2QELSbxPGXvsAgDq21RA7ww+EcuQEpLfWWZGmy8
         voJGXB80/V6GK9bTft1y1hnmXGJzhILITVPG/MxZVR09MCuhK5VTCdjSN/wfSeeD+Wdf
         Bi6Q==
X-Gm-Message-State: APjAAAX+0YfCHuy0Nbjy/CJsSjCq2VQ5dz9+hHwicus9yHZtRnaKPedV
	6cpQGzj/s9dZyVcGXZYG1tufVgT/sBvRwoZJ50/nFY5o5zVKbpURrk3rMZAZ5ah+r2574KBgVMC
	FTDThT6/r1IJthN23vhK7/d3zRmSy4sdIYGkQIU0e6Bit83beLUyeOevXzx5I/VZQ0g==
X-Received: by 2002:a65:6554:: with SMTP id a20mr6968734pgw.170.1551476652798;
        Fri, 01 Mar 2019 13:44:12 -0800 (PST)
X-Google-Smtp-Source: APXvYqwCdkSRb7wPyb5FbSso+xUl+6oE4WL2PuT+ndRJ4kiNZHhkrOfMN83FVSjy4Gtc7vZVnvYk
X-Received: by 2002:a65:6554:: with SMTP id a20mr6968675pgw.170.1551476651680;
        Fri, 01 Mar 2019 13:44:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551476651; cv=none;
        d=google.com; s=arc-20160816;
        b=cuHSPEntfRpEwrqZgh8qXMtuJjfdDpLgCNMwXZoIX5YkqMrvFOGLZSQFSK6dL9C0rL
         kegydGeQIdFoxJzl5+aJkZsUAlYN77NOiZI8hv+LLz4nzzBbbVCU34IPrB1ALXBkZ5lZ
         mAu8Fzx4QhiWQAey8o6cRMi+fRL6jflQc2Be8o1RZ7CuymhcivBlklXy7nf9n3kDLzQG
         vE2M/PyMtYEq5By5IpJnOZ3LaiIbocdmTLaJnwruQClJhCvLPxSJKLL23ApOcIJP3QZt
         jWuoLbNcDghyJGrRtW73vV0nwGUk7rMqnwIAmvKkVLNIJRCdiB05rjX8Ck1q5LpBoxW/
         KrqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=I9/CQcAMDAqcYCsl2DT89h8s6NYBhCyEInQQWC9dKTs=;
        b=j4W49NoexjDO/HuFyaVIJXLL8vDF46mF8r02lEC6iXdqne2T4kp2OFesmJR3mYDBGc
         Jwh9ESqGXGytHVklC+VmFbnc6/sl1IKx5tkU5kMuRrSkuCWdVLKYAk59ipB5Ll9ucWhW
         qgqRxViK/JUfOfV3aKh4Pp45+itfsDiicYg+f/opy9XdZuqzmTanGUVcZq9jZ8f/3Ltm
         LXk96UxQtO0dXzRKPju1PIE5w5xrPIzVvrKVbkWp5t+a3SML9L5Se3+0w3j6WLXkFIug
         PwNT7lMUeMdkkp57655vDYoUrdG2n6+X5R9ccvNBOem35CjSVY17YisA3s8UqBKGdwrp
         CQQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="gZsx/MRd";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id gn14si19621154plb.171.2019.03.01.13.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 13:44:11 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="gZsx/MRd";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=I9/CQcAMDAqcYCsl2DT89h8s6NYBhCyEInQQWC9dKTs=; b=gZsx/MRd9hanHUjfdTuQVYJ+C
	nMOzKwG7k5f3/hFIoZjl9bGK+TIAnhAdQ71G/l4JOONFkCLZfHCCas7fec/JZlay0d5cFRXtDG3U6
	94w1fdTGs6AEuu1MwMW36NKO9RId79VIBJ/u+14EAaOwGD2w09Wg/SgZYZobduenYb+RQhVD74cFt
	74k2UCTIAwt+Ev+aUYu+5QyyNfRHHln0h5YJkVJco0iIo61CxEfVINQh/n0iA/Y2eZT312XZ3TqKW
	s56s+Tey92hu5qTFTmyofQXF3P+/HJw61pPCUfXS538kj/aHcWe9zquT7hbdB3h74TI2vukxg1ABY
	eNhHwKY4w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gzpww-00049o-JI; Fri, 01 Mar 2019 21:44:10 +0000
Date: Fri, 1 Mar 2019 13:44:10 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hugepages: fix "orig_pud" set but not used
Message-ID: <20190301214410.GO11592@bombadil.infradead.org>
References: <20190301004903.89514-1-cai@lca.pw>
 <20190301130951.67f419011da93265d36226cc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190301130951.67f419011da93265d36226cc@linux-foundation.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 01:09:51PM -0800, Andrew Morton wrote:
> On Thu, 28 Feb 2019 19:49:03 -0500 Qian Cai <cai@lca.pw> wrote:
> 
> > The commit a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent
> > hugepages") introduced pudp_huge_get_and_clear_full() but no one uses
> > its return code, so just make it void.
> > 
> > mm/huge_memory.c: In function 'zap_huge_pud':
> > mm/huge_memory.c:1982:8: warning: variable 'orig_pud' set but not used
> > [-Wunused-but-set-variable]
> >   pud_t orig_pud;
> >         ^~~~~~~~
> > 
> > ...
> >
> > --- a/include/asm-generic/pgtable.h
> > +++ b/include/asm-generic/pgtable.h
> > @@ -167,11 +167,11 @@ static inline pmd_t pmdp_huge_get_and_clear_full(struct mm_struct *mm,
> >  #endif
> >  
> >  #ifndef __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR_FULL
> > -static inline pud_t pudp_huge_get_and_clear_full(struct mm_struct *mm,
> > -					    unsigned long address, pud_t *pudp,
> > -					    int full)
> > +static inline void pudp_huge_get_and_clear_full(struct mm_struct *mm,
> > +						unsigned long address,
> > +						pud_t *pudp, int full)
> >  {
> > -	return pudp_huge_get_and_clear(mm, address, pudp);
> > +	pudp_huge_get_and_clear(mm, address, pudp);
> >  }
> 
> Not sure this is a good change.  Future callers might want that return
> value.
> 
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1979,7 +1979,6 @@ spinlock_t *__pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma)
> >  int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  		 pud_t *pud, unsigned long addr)
> >  {
> > -	pud_t orig_pud;
> >  	spinlock_t *ptl;
> >  
> >  	ptl = __pud_trans_huge_lock(pud, vma);
> > @@ -1991,8 +1990,7 @@ int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  	 * pgtable_trans_huge_withdraw after finishing pudp related
> >  	 * operations.
> >  	 */
> > -	orig_pud = pudp_huge_get_and_clear_full(tlb->mm, addr, pud,
> > -			tlb->fullmm);
> > +	pudp_huge_get_and_clear_full(tlb->mm, addr, pud, tlb->fullmm);
> 
> In fact this code perhaps should be passing orig_pud into
> pudp_huge_get_and_clear_full().  That could depend on what future
> per-arch implementations of pudp_huge_get_and_clear_full() choose to
> do.
> 
> Anyway, I'll await Matthew's feedback.

I'm not sure it's wise to diverge from pmdp_huge_get_and_clear_full()
which does return the orig_pud.  I agree we don't currently use it,
so maybe we should just change zap_huge_pud() to not assign the return
value from pudp_huge_get_and_clear_full()?

