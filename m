Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 421ACC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:32:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E88BB21900
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:32:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gc35xBK2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E88BB21900
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 661398E0004; Tue, 19 Feb 2019 00:32:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60F448E0002; Tue, 19 Feb 2019 00:32:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FE4D8E0004; Tue, 19 Feb 2019 00:32:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 296E18E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 00:32:09 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id i65so2635323ite.3
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 21:32:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N3a1F+phTWNP4vUdqbdRG2LlbC8gmOfizcSGQCqcX2o=;
        b=YkjArOKnpgzOIa1/kAYCS7CYRSBnzJ9W1fKG4MaWyC+xBekE0FIGr42cuW4NGT2U7f
         2vQvgFPLsn3BLlZDQ+EFuAfSc1jBidhdKw99UiXpuNwjTKs6Po0Now94NfTc0bE4w9fO
         UdBUp8144MDul+QjgW/LVpaP1UbCfaXusWUhsml9Ql5I7h6gs+rFdgZmRb8GRYd0wSmd
         +DjxTfTWRu86vS/zyLYzzqJBN0YTKGkw5mX9tthWjUT4xxn7YNANL24QsVOkpPWN/09z
         ZJO3FrETPIlXKVxxspsBArIOi7G7l5ndn6vJooXC1WNTxxEU/CEnkG9aKXieFzqvznNM
         RpmQ==
X-Gm-Message-State: AHQUAuaWzaRJXlJCvm9FlYzYgNHNpFqwd+gdFLH+W8O8q3OYvxRH+UCr
	p3zx1gug5A8BN+kLOBgWArPhXdHUy9L5K4FtyZvTo0+GyiWM9veR+1D8Xc7ZfUldaW8qVHI8tul
	Yrt2qhDaplF4x4GphRTd/d2HyYKySoHnCB188+M9YvEfMpAnw2KdtIk4vSLQZukWmJjE8iyXwSk
	yeH7ACeGaWpcON0IaK/UcyngR/zIZpGJewfi610prgcgDQbMTcG6sAQjXGIhDEVGuTUKME5iJiZ
	GLvEpaQeYY2lkavYFhPLF0R+SGUI2hO6LgVOpjtL/OlDChnfRuKS+yjm/xV1qoR6sg62ISHUdNc
	cEY7SpMnhnqiR1oKrhanyONkZjcweYWMvTLgCWbY2nIudjWfvexLJDbnx5+KFQo3ko8PdkkhIxc
	4
X-Received: by 2002:a24:26c4:: with SMTP id v187mr1450493itv.54.1550554328862;
        Mon, 18 Feb 2019 21:32:08 -0800 (PST)
X-Received: by 2002:a24:26c4:: with SMTP id v187mr1450477itv.54.1550554328261;
        Mon, 18 Feb 2019 21:32:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550554328; cv=none;
        d=google.com; s=arc-20160816;
        b=GzHvv0W0UnappmHZZs+8OtUy6lZO4rYGhIc2qjmpkjImKnyQfZv3QJSk0Fy9bOLzGM
         TIMUT3WrHpcKKZfN/9tRs8/k6AFva467s9iA2flen8zc5XRwthhUB+YZ79swxPEv5139
         bW85b32O64SFhk/qdlA9nYUZkEzBLU0Tgp3PE6GW9TADilyZJ+xqIdCnhrwa3K2HY9Uc
         4rPF0QDx3G1cYN5MQJSQSeoXpt92VYIeAWnT6Suao0gC74gYygffjDaHylsmfBCydT6u
         8t4gqX69er6O0YFgr8mEWS1WfdFI3qYuy9Ej+GBqy4933Rv0XgW17wXRAVKOqVEaCbkK
         XzTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N3a1F+phTWNP4vUdqbdRG2LlbC8gmOfizcSGQCqcX2o=;
        b=0I66xTMGx4TahhnXC6tQELcBdovndXPFSXAKnjwlb6PnDPDepRPO1cl4j2U56N2wiX
         oLUpkT+Lpkw6nAnI4zPSoz5IhIJ3Oo3ddknyGDC60Gd5Euv/CdujBB940mbjPDZT298V
         uvoq++z02v6G/tHkUhtb6EGO+D8soggvoa4f4EKsSlbseQxnkrkgLiyixzetP6y6D/H2
         E9gd8ybtMrpC39ODylYkCHCBJIqghY5CtjJTRNxFsSXrFVEjKGtIuPqFNUMnr5mBk/GR
         +t4T1BTRIGuuX6MZ7PbsMxUUfj/vbcVsilZijprWLl3Tpz/QKGHZ7LOsvtBKs70klAMo
         Vm9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gc35xBK2;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k9sor7935908ioc.50.2019.02.18.21.32.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 21:32:08 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gc35xBK2;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=N3a1F+phTWNP4vUdqbdRG2LlbC8gmOfizcSGQCqcX2o=;
        b=gc35xBK2JBhKjw035oTY1u93BDW82QcWBUDh0TI0DviPy3CeCAzv7UjcT9TBy+JNXD
         lXsqfikYlopTFD18nTHjmmRrxttVYtwzVpdrcmcShD2mF0FD+Y2mPGor4BJ+JyWMkPEF
         4WDiECLbmuY+tNd3wpir2eUCE5HFOoUVxhvpG6f8UjS7IMrSRDbkoXfZbnvCnf1E+xpy
         Gb2iaVw9vsJrlo8mFuMRiG9pQMgi2y9rMP6W/VBNr1Pq8BIMegopo5fRM5cCHHRzONVc
         O/Xlf5nReRAxB9UeaX5jp8SO8MCBrq7et2MGGu2s6g7pXO7MPqGB0DajNG+e+Z61lxQj
         25UA==
X-Google-Smtp-Source: AHgI3IZ5ltUtXza7ruJZojlSoyiNc3n4l7gI2q26hEETIjvCNdzWMCapc6G79N9F+MyPSvpcyvD6wQ==
X-Received: by 2002:a6b:4a09:: with SMTP id w9mr17157160iob.260.1550554327823;
        Mon, 18 Feb 2019 21:32:07 -0800 (PST)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id k26sm6197007iol.14.2019.02.18.21.32.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 21:32:07 -0800 (PST)
Date: Mon, 18 Feb 2019 22:32:05 -0700
From: Yu Zhao <yuzhao@google.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190219053205.GA124985@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 09:51:01AM +0530, Anshuman Khandual wrote:
> 
> 
> On 02/19/2019 04:43 AM, Yu Zhao wrote:
> > For pte page, use pgtable_page_ctor(); for pmd page, use
> > pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
> > p4d and pgd), don't use any.
> pgtable_page_ctor()/dtor() is not optional for any level page table page
> as it determines the struct page state and zone statistics.

This is not true. pgtable_page_ctor() is only meant for user pte
page. The name isn't perfect (we named it this way before we had
split pmd page table lock, and never bothered to change it).

The commit cccd843f54be ("mm: mark pages in use for page tables")
clearly states so:
  Note that only pages currently accounted as NR_PAGETABLES are
  tracked as PageTable; this does not include pgd/p4d/pud/pmd pages.

I'm sure if we go back further, we can find similar stories: we
don't set PageTable on page tables other than pte; and we don't
account page tables other than pte. I don't have any objection if
you want change these two. But please make sure they are consistent
across all archs.

> We should not skip it for any page table page.

In fact, calling it on pmd/pud/p4d is peculiar, and may even be
considered wrong. AFAIK, no other arch does so.

> As stated before pgtable_pmd_page_ctor() is not a replacement for
> pgtable_page_ctor().

pgtable_pmd_page_ctor() must be used on user pmd. For kernel pmd,
it's okay to use pgtable_page_ctor() instead only because kernel
doesn't have thp.

