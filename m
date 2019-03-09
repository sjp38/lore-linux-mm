Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E274C43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 04:02:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CF0D20866
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 04:01:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="enB8NIwm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CF0D20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7029A8E0004; Fri,  8 Mar 2019 23:01:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B0638E0002; Fri,  8 Mar 2019 23:01:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A0338E0004; Fri,  8 Mar 2019 23:01:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 327B98E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 23:01:59 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id x22so17018545iob.10
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 20:01:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pH8sAGGnXCkPUbMJRChks7/3dKNz3dpZwqyj91moOWQ=;
        b=rioDF1sg/uT3sLfr7ZMd9hh2nAZmu9YqUfQJPXZW49bEYO2Np742cOMquJo/fj2AGe
         Cd6O+QpZCnLgsJUIeQxLdqA4U3HonPKHsb0lIhth4pKS0GNko1TR5gsdUEGeiUeinvRu
         BhmYbbOj/LD442dpkDGTS/kIfMcuqXSdnazAdJVFqIzrTIuM+nWMtuSrFgVCxDpKAURj
         TBzpO9N18V7LxAmRrcGVqwfHTT93ueoW/a2LRnWJFtsnPguU9h/baKFImZtgNUHvjCTG
         zrLEt8yJo1ppOAYt5ByT1OhduUdzpooeBtX/FdEab2n0/G9xbuzVgTmVsZ676h7n5L+A
         jNsg==
X-Gm-Message-State: APjAAAVNKHhQx6KGVpHpIMWN8cd9/XoDM/IlXlWZB3cH59Q8zmYsdb4X
	2Rhh4KCuX7wN/v6jNsR1ZmPuqy1+bX3l5PeGq/GVgWpI25knqbW9PhUH+pEVQ/f1mY3/ABYZCmD
	awRmcln2X0kXgyqoZGf2JeoVFM+ke+jOwur33ZMvWk+9sphUJwAxOp+2v4k8gqw9YVuBD32PLiR
	H6LQ5u/J8tI9N8aHMxVYWG0ZTZ0SeYemRe2pjKQi7dgaEhRQOpnn5eh8K5i96z7TTr+aKg0yOCe
	c2RGaVgRO2DLrhn0lcvf68SOlyqVNgxRAbp17hBqA7pCa0maVWCg5zw2jwWihSi9Wiczx6eifa2
	BlykXmyDI0RVrWeJMI0EXA7I1DKZIyLK5n9+1FNKNPPwX8sHdzgNDxOqp6RBMsr0tzWnhAQKiOY
	f
X-Received: by 2002:a24:3d0f:: with SMTP id n15mr10649106itn.1.1552104118937;
        Fri, 08 Mar 2019 20:01:58 -0800 (PST)
X-Received: by 2002:a24:3d0f:: with SMTP id n15mr10649088itn.1.1552104118107;
        Fri, 08 Mar 2019 20:01:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552104118; cv=none;
        d=google.com; s=arc-20160816;
        b=sSoF6evs/QRfJMoWeOuPYo6BFCOwgGw4Pu8EaEzn4sF20VC/9NXB97QKEpO1B93eME
         ll0T0E0XQRsa57CFGJ3kFebYFnWT8Zjq5ClQiCEfNf3VA7+o4ZdT1qU+8kk2WrG/toy8
         eH49vAu4HYlJmmkb7E0YcmB9nAvpqBj41tjZWjoCDG2iGuxpvr2qjvHCfe9RRHf0HLx/
         6oWePz4zmQsKf7YyRdRU7Sr4PuEpJBtVd7o/Y7QaUi5dpwB36GqKgAhCa22MqFXOCGAs
         6pJ95rjIlUihRnTvrxluJwl8A/O52lJJPmRJ2C5OhxT+N/NgtlDonx14/fT/arFP4aEL
         tt8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pH8sAGGnXCkPUbMJRChks7/3dKNz3dpZwqyj91moOWQ=;
        b=DcwGOS1+rOuOtSlPSl9qgjeqgAv9tAD6+NdEuVK5dQOuFtXV07f680fNjtzY/U8AYB
         c28uBGPqTJUoPnlvjs6dX3sHxtFT9ZSeagY1Hw/ADmnfCnf1hSQIC+26BzucveSd0nLB
         Ma5pdSt9px1AIiarE+V6G7S+uFWV58KTAPLZiKQNnBOlnP+icQGEnfv+z2NSmV4ESm2O
         RKJrkBewvOYMhDpkGGe2JOMAHBjYIl/LsWm7/3JfFo/m/pe1OTDoX8i2/uTmB9hOgCJB
         tydfm653OUts9v+yC4lFzD53wdLqYai4khBSZ8UGWslmh6aHUD19RZgdSo3VK+ew/RPE
         KHYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=enB8NIwm;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q135sor16805466itb.16.2019.03.08.20.01.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 20:01:58 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=enB8NIwm;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pH8sAGGnXCkPUbMJRChks7/3dKNz3dpZwqyj91moOWQ=;
        b=enB8NIwmaJi4OQIxi6Q/xvZ0q+BraSiTqy2d+wEIOPrVqPSROmqMNQgomRAX4Fy7FD
         aU78a/tdjiDj1/km2nvCbgYpYF9620eRVkuVKCsDdfCUQUAsyg8tR2d/2/z+p9F8ciy0
         jp8jVPyYgGRg0vxFP2Z+iW/sp6FGoTiBKNf3gWO8vlKBn/8fLJo4Sp37mSN0IIgTQajl
         PtSqL/rRPvsI6d3mF0YCccXv69WCZWvqLWFV2M3Wz4F+VaUtRs2GXmeDFv9jOuWXSSb1
         cRPA6JKp79uuMAhwfOnwo60sTRoe1HWGlcGwVh4jlOA2wSZsKXqv3SbwFfbJrR5OvO7i
         6Jgw==
X-Google-Smtp-Source: APXvYqxw7MTdz7bi6mEtWop3jiCjYq5/KwPLeoWLGPADNTbYqSyrAqSKBzbVkN9Z2kxcgJUuJ4Uj3g==
X-Received: by 2002:a24:7690:: with SMTP id z138mr10329033itb.119.1552104117606;
        Fri, 08 Mar 2019 20:01:57 -0800 (PST)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id u82sm4882605itb.18.2019.03.08.20.01.56
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 08 Mar 2019 20:01:57 -0800 (PST)
Date: Fri, 8 Mar 2019 21:01:53 -0700
From: Yu Zhao <yuzhao@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190309040153.GB214016@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <20190226151230.GA20230@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226151230.GA20230@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 03:12:31PM +0000, Mark Rutland wrote:
> Hi,
> 
> On Mon, Feb 18, 2019 at 04:13:17PM -0700, Yu Zhao wrote:
> > For pte page, use pgtable_page_ctor(); for pmd page, use
> > pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
> > p4d and pgd), don't use any.
> > 
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > ---
> >  arch/arm64/mm/mmu.c | 33 +++++++++++++++++++++------------
> >  1 file changed, 21 insertions(+), 12 deletions(-)
> 
> [...]
> 
> > -static phys_addr_t pgd_pgtable_alloc(void)
> > +static phys_addr_t pgd_pgtable_alloc(int shift)
> >  {
> >  	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
> > -	if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
> > -		BUG();
> > +	BUG_ON(!ptr);
> > +
> > +	/*
> > +	 * Initialize page table locks in case later we need to
> > +	 * call core mm functions like apply_to_page_range() on
> > +	 * this pre-allocated page table.
> > +	 */
> > +	if (shift == PAGE_SHIFT)
> > +		BUG_ON(!pgtable_page_ctor(virt_to_page(ptr)));
> > +	else if (shift == PMD_SHIFT && PMD_SHIFT != PUD_SHIFT)
> > +		BUG_ON(!pgtable_pmd_page_ctor(virt_to_page(ptr)));
> 
> IIUC, this is for nopmd kernels, where we only have real PGD and PTE
> levels of table. From my PoV, that would be clearer if we did:
> 
> 	else if (shift == PMD_SHIFT && !is_defined(__PAGETABLE_PMD_FOLDED))
> 
> ... though IMO it would be a bit nicer if the generic
> pgtable_pmd_page_ctor() were nop'd out for __PAGETABLE_PMD_FOLDED
> builds, so that callers don't have to be aware of folding.

Agreed. Will make pgtable_pmd_page_ctor() nop when pmd is folded.

> I couldn't think of a nicer way of distinguishing levels of table, and
> having separate function pointers for each level seems over-the-top, so
> otehr than that this looks good to me.
> 
> Assuming you're happy with the above change:
> 
> Acked-by: Mark Rutland <mark.rutland@arm.com>
> 
> Thanks,
> Mark.

