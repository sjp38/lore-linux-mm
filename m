Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC606C48BE3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 03:16:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F2B620663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 03:16:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F2B620663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 316396B0003; Sun, 23 Jun 2019 23:16:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C7388E0002; Sun, 23 Jun 2019 23:16:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B5F28E0001; Sun, 23 Jun 2019 23:16:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E491C6B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 23:16:30 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f36so6791665otf.7
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 20:16:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=s+o19WiPcK3mXxp/efCKUndjBRLOvOE8J3TM0BELZC4=;
        b=UsD1s6Z/87K9X92K4YsvemDbBumE87Wb1/2bRsVav2W8Uu6IBgUs5ZkolT6kd4stES
         +uHQz4CYZsS1aUZOZ/TvW3PwH77U5MszRK1JoUe5MLRDuh00qWF0Nx3bzFMxxk/DWqnq
         ca4Mwxmz5Zf+dAMM+MUVbxguXkT9eXvANbg2KJB5toasWdju+JLHlmte6QdzK1wO/5Ix
         bjLmMEg/PpeHTQc67X9ROiUbY554VdyfFb424iFKEZacH7jkEV9JmNpEWztamjdkO74l
         CDPKROgBYkhyg8fcyzyrYRdgD00Pbb32eHgdgxKbVJrRbLS87yJVC2KqIReOdzMYhf7o
         myBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXh69r4BCYcd/U/VNdGe7/uvIzwtikbC1ggGm4x73pi/sAuLmDZ
	bmRLT39b9RdGnHAHzcsUquJj03bZq93IB5XKnGN/rufQL6gRHdI7JYAOgCQM4RMV4j9iMH6KH22
	IqPV0ri54II43ABIFIIlKecvB0PPOALkgJki1MW00AB14aXUwU4wrLsqMUxerLF4KSw==
X-Received: by 2002:a9d:6a19:: with SMTP id g25mr27209692otn.77.1561346190527;
        Sun, 23 Jun 2019 20:16:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweRPszPJTyg7gwehM/SY55UssMMbrNoKayFfE8Cfmbg/l77VeigKRjohoZNc6GiuwoeXV4
X-Received: by 2002:a9d:6a19:: with SMTP id g25mr27209666otn.77.1561346189847;
        Sun, 23 Jun 2019 20:16:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561346189; cv=none;
        d=google.com; s=arc-20160816;
        b=fA6eVFUxVsIZ5KUdOQCF026mXTFKmbaYyZeeyx4J0sMdM8z4/98Eb4RpIMXtHPAsQm
         l9DsYSLYSJjIxA96Tv8JOLziQ8S7oV1iISF7S5qH5a3jkS3udqH4KhaiUUIZKhDOTger
         N6b/P0AFSzPADjxDWuwrQ0wLuqqmaXuJTmOAxfdDmeiHw/n/5A5X9MoFRHmoSZH8BNXQ
         boMJHdggC2wDUZ1vumSNQ9MwyHBTrk/hr4iMdBM9q/jnAgr+0ntp8VmYRiWpHnCz9+5T
         7e99qwuZtxeTl0UiiGxdmjtqwew6285/YSoNlJQYSA/AH3d6v2ZLicmwKyEgOBlE7//j
         xkdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=s+o19WiPcK3mXxp/efCKUndjBRLOvOE8J3TM0BELZC4=;
        b=x+9MUFWf5BSzajKnMhciiTlt3XC3FG/h+rZSC62ZqH+Owb2DuNV6XlCrpOuRvNxIgk
         B9Q9O7ujpQQulkN12ijKwT/NYX0spEmlmep+uyqVi8vU1l3kdBSSO1oAPIyxgoSy/4GP
         xfuaz9jbwiwr55JEz3z7vRqQUcCHKFhE/458GyZam9Dfk5PXERAXrLXVbLbWblqPhFzR
         hkW7eJ6oAgYta7YF8y6TvKdMOQR1s1SDoT43UASVEEYjNbv+HfjD9DJZtVyD2KGsGFKQ
         rRytRU2wsvM2TsSw9pue10NwDMqJUHo0RccvzHtbpRaISRYtJobd8aeLyqSooyzmGVcU
         cBdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-166.sinamail.sina.com.cn (mail3-166.sinamail.sina.com.cn. [202.108.3.166])
        by mx.google.com with SMTP id b189si5720521oia.2.2019.06.23.20.16.26
        for <linux-mm@kvack.org>;
        Sun, 23 Jun 2019 20:16:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) client-ip=202.108.3.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([221.219.4.32])
	by sina.com with ESMTP
	id 5D10407B000035F4; Mon, 24 Jun 2019 11:16:14 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 282986395259
From: Hillf Danton <hdanton@sina.com>
To: Song Liu <songliubraving@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hdanton@sina.com" <hdanton@sina.com>
Subject: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem) FS
Date: Mon, 24 Jun 2019 11:16:04 +0800
Message-Id: <20190624031604.7764-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem) FS
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hello

On Sun, 23 Jun 2019 13:48:47 +0800 Song Liu wrote:
> This patch is (hopefully) the first step to enable THP for non-shmem
> filesystems.
> 
> This patch enables an application to put part of its text sections to THP
> via madvise, for example:
> 
>     madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
> 
> We tried to reuse the logic for THP on tmpfs.
> 
> Currently, write is not supported for non-shmem THP. khugepaged will only
> process vma with VM_DENYWRITE. The next patch will handle writes, which
> would only happen when the vma with VM_DENYWRITE is unmapped.
> 
> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
> feature.
> 
> Acked-by: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  mm/Kconfig      | 11 ++++++
>  mm/filemap.c    |  4 +--
>  mm/khugepaged.c | 90 ++++++++++++++++++++++++++++++++++++++++---------
>  mm/rmap.c       | 12 ++++---
>  4 files changed, 96 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..0a8fd589406d 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -762,6 +762,17 @@ config GUP_BENCHMARK
> 
>  	  See tools/testing/selftests/vm/gup_benchmark.c
> 
> +config READ_ONLY_THP_FOR_FS
> +	bool "Read-only THP for filesystems (EXPERIMENTAL)"
> +	depends on TRANSPARENT_HUGE_PAGECACHE && SHMEM
> +
The ext4 mentioned in the cover letter, along with the subject line of
this patch, suggests the scissoring of SHMEM.

> +	help
> +	  Allow khugepaged to put read-only file-backed pages in THP.
> +
> +	  This is marked experimental because it is a new feature. Write
> +	  support of file THPs will be developed in the next few release
> +	  cycles.
> +
>  config ARCH_HAS_PTE_SPECIAL
>  	bool

Hillf

