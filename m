Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37DD7C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:23:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D77B52148D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:23:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gZKWQc2K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D77B52148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7306E8E0003; Mon, 11 Mar 2019 19:23:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E25F8E0002; Mon, 11 Mar 2019 19:23:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F7218E0003; Mon, 11 Mar 2019 19:23:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 380DD8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:23:30 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id 142so646384itx.0
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:23:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2Iy+HRoKGbvYIX/HJ/Oa3YNfE4vvNj0SEEupfHgAt7I=;
        b=JDRAeyuVC/AljBYeb4aVeeVv9xo7IdAM5HkI1pe13UcwcXhvbr/MQiY9loCalHTE3M
         sjmgzApw8l1PrV4YmguEbF7UuPArE6WTuzy1DYceTh+3wB5MbRyRPgE7cUboyBY1uVaB
         gUsS3F3HLjhnTKnqYxjfDz5d5UU0lG+3OHSk4F88IU8hI16YME39PCGhpj+uTIgJuggW
         cK+4XDjLMO9KsBpuH+y3WRDs5osM0CCzzH0SwRS7sqg0y9FhKG1VFBqs7Gq4JsHWzgqo
         /wog5iRhpXUewiPlUJqZ2YJ9jsEz61ernNS+rY6W96lCzC67mX4K5u4h88igjQnych5I
         wdnQ==
X-Gm-Message-State: APjAAAV3Q/COZyNQYqtmaTdDMXzosjy9ibDMRNf39rDC5EYUtSLJOJ3e
	nRDSgXE2CP0giwvP57Lyw8/YwVWawcfKS2X9iJLpcpd1cx73tyTth5o5gDnVterNVHOCe9tq2TB
	m3fkyUxzjusFvt2rkjsPt6hL+vFA2FTbC/jmVMrjp7nuOqWS0JNzHaiI2pZSjut1IbKF02ScwJG
	yOsJgAW1IBV99eWCTwohcgJm4fsAXhch3XuJFOW/PGnyQHaRdFqhyW813ym2z85aJU/HVJ+6gUw
	PZ8MCSxFwUHIOimIEqEouCa+CQ43j1+3Xg+zC0nxQ4sIM/CXgW/YIq9Hz7bIuYlVrrTBAcpcRPQ
	kwto5hdu3j43pfpL2lYwgv+H5Cv4Uj+TnUc8Vhb648V3g5RhwjMDvs7ilgXOSSr7RGd0mUYL9ZJ
	x
X-Received: by 2002:a5d:8d84:: with SMTP id b4mr17975631ioj.109.1552346609959;
        Mon, 11 Mar 2019 16:23:29 -0700 (PDT)
X-Received: by 2002:a5d:8d84:: with SMTP id b4mr17975597ioj.109.1552346608614;
        Mon, 11 Mar 2019 16:23:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552346608; cv=none;
        d=google.com; s=arc-20160816;
        b=GhkJiL1llXdNDZhHYmaF5FJjPyVP3BLkYneg5ya1Za8WTnIuhA/JNN5J5v89OxiFI/
         loaJjVRfMAfG1nuzYlZPbDBEuKAIbjB/Xls/IU460XM1AJ28h5SIgOJvc6d1HnggBVFn
         RNo6YG8iEgVof71Q9MWFLSS4p1m6mwqq/ELwZRCiQIM3mY/Q3ewAC/s6VlmqzAezL/cO
         ok88m5kgOSsbPBbHbaqCPLKjBvgT+RbDMjaufVqDiNJHyVqD8MSx0h61xK1B+lV1KfKE
         Kz++GYM5G9gpgvj/7LopJIsZ1Mz+9f+IGAPSIDxV8+5xcpuEEn6/a3Am9h6NWj4SOQky
         4/qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2Iy+HRoKGbvYIX/HJ/Oa3YNfE4vvNj0SEEupfHgAt7I=;
        b=Fk+eLIfBGoCobvVB8/hPErb0KYXe9NH2K0T+ccnR+fZoQZr7Uq9UifjVeH6O86Cuek
         2YO+Zs7tIggMFurTtFKL/d7EZ5dqGyS6tKW+Xu2nCecF9vkb1yeEYDPipyiHGtdzsvIj
         t7QJ4Mdx8gQiPE1uKakaXJgjnmswPURMZJ/k+52qEabHG4TVCBa9JjN4pf+2fSjzl8ie
         9+hiz7hYSOf45UUdhl1rOBBj7RjDhZtDT6eVAz2IEtevOmHr0R06r/eX3lV8R/bqxMa5
         kKc63V7uIExkVa3o7yaXyP6CZtptrpHrNMSniZrN3Dg3d24KRO5c7kDchMONMt+MQuxK
         pYag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gZKWQc2K;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 184sor1034231ita.36.2019.03.11.16.23.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 16:23:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gZKWQc2K;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2Iy+HRoKGbvYIX/HJ/Oa3YNfE4vvNj0SEEupfHgAt7I=;
        b=gZKWQc2KYwGAX3WowtGwdPrVrqqb8O6bfCdDhL1oyXMRPps7k/Zwmb6pXoM+qjET4y
         ip+aHfBkpp8BwRnBmV+PyaqmdFa+7T1XGd8BqUKvbh5hD9u0P3rz93oaPt9Eq6HsGs34
         jgRj/Whff2r8sgBtjJ6NkZFimIloBJzAodGLYhC9pLsH5dCg26QMKYR9Vzm+6Vf5e0YZ
         8cyq1PVFJILFTXtWlv/sVYeRRSjHGjMpPsYhXYXbjYX/tar0JYGUR63GNmlD8XOTUxMR
         +Dx6uSX090lfloxgp8KMYGqDlUaUNZm6h/JcRcxE1Sjm2keTgiwUwkSFiBhmWg7CVxi7
         BSow==
X-Google-Smtp-Source: APXvYqyPGkSJFsx3J+ev890Ozq1EHLT5IDQIVnuh3g3snXm234Vr+JhVinPiWYKVphuheOwwdBLDpg==
X-Received: by 2002:a24:c4c5:: with SMTP id v188mr448374itf.27.1552346608185;
        Mon, 11 Mar 2019 16:23:28 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id w127sm443830itc.4.2019.03.11.16.23.26
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 11 Mar 2019 16:23:27 -0700 (PDT)
Date: Mon, 11 Mar 2019 17:23:23 -0600
From: Yu Zhao <yuzhao@google.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
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
Subject: Re: [PATCH v3 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190311232323.GC207964@google.com>
References: <20190218231319.178224-1-yuzhao@google.com>
 <20190310011906.254635-1-yuzhao@google.com>
 <b0ae4f65-aa0f-148a-eced-0d9831a7bf01@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0ae4f65-aa0f-148a-eced-0d9831a7bf01@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 01:15:55PM +0530, Anshuman Khandual wrote:
> Hello Yu,
> 
> We had some disagreements over this series last time around after which I had
> posted the following series [1] which tried to enable ARCH_ENABLE_SPLIT_PMD_PTLOCK
> after doing some pgtable accounting changes. After some thoughts and deliberations
> I figure that its better not to do pgtable alloc changes on arm64 creating a brand
> new semantics which ideally should be first debated and agreed upon in generic MM.
> 
> Though I still see value in a changed generic pgtable page allocation semantics
> for user and kernel space that should not stop us from enabling more granular
> PMD level locks through ARCH_ENABLE_SPLIT_PMD_PTLOCK right now.
> 
> [1] https://www.spinics.net/lists/arm-kernel/msg709917.html
> 
> Having said that this series attempts to enable ARCH_ENABLE_SPLIT_PMD_PTLOCK with
> some minimal changes to existing kernel pgtable page allocation code. Hence just
> trying to re-evaluate the series in that isolation.
> 
> On 03/10/2019 06:49 AM, Yu Zhao wrote:
> 
> > For pte page, use pgtable_page_ctor(); for pmd page, use
> > pgtable_pmd_page_ctor(); and for the rest (pud, p4d and pgd),
> > don't use any.
> 
> This is semantics change. Hence the question is why ? Should not we wait until a
> generic MM agreement in place in this regard ? Can we avoid this ? Is the change
> really required to enable ARCH_ENABLE_SPLIT_PMD_PTLOCK for user space THP which
> this series originally intended to achieve ?
> 
> > 
> > For now, we don't select ARCH_ENABLE_SPLIT_PMD_PTLOCK and
> > pgtable_pmd_page_ctor() is a nop. When we do in patch 3, we
> > make sure pmd is not folded so we won't mistakenly call
> > pgtable_pmd_page_ctor() on pud or p4d.
> 
> This makes sense from code perspective but I still dont understand the need to
> change kernel pgtable page allocation semantics without any real benefit or fix at
> the moment. Cant we keep kernel page table page allocation unchanged for now and
> just enable ARCH_ENABLE_SPLIT_PMD_PTLOCK for user space THP benefits ? Do you see
> any concern with that.

This is not for kernel page tables (i.e. init_mm). This is to
accommodate pre-allocated efi_mm page tables because it uses
apply_to_page_range() which then calls pte_alloc_map_lock().

