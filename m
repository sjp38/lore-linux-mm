Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E96AC76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 00:30:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BEFB21880
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 00:30:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XsSfkiST"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BEFB21880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C65BD8E001D; Wed, 24 Jul 2019 20:30:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C15908E001C; Wed, 24 Jul 2019 20:30:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B04928E001D; Wed, 24 Jul 2019 20:30:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78D9E8E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 20:30:58 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so29678082pfa.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:30:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aXeA4WNumL8ce2q31xsEhnW9xNk+0Px0w7z/1Z2NZI4=;
        b=FjqNOh/43Cyj8gixbD4BICDxpbyBlbkV2q2NrwyFvzHGraNzMle2rXtRRzsOcTf42Y
         NC7DTYTBuP8CDuuWtCO/YMhL/cg3k5S1xy9qS1c71/62FBz278CqTVJKoPRCXYuWBLvk
         kyJIde6cSv/b6bIA3KcATbqDSk4z4OaG2LMyICQeTdrBtyeP1thqllz4frCyHvWqAH8Z
         QzX3PZ1ee0RlVpajEjv2I9YO1YzyhCIE1FO+WIjQCuhqgRgPulNM8nlLgBRwPKHprSXl
         +s3op6xWsbNSua2XXcjVNRvUKxxT59/t3bqefI93k1NGNbIBsGCaliVUNtX2FB8iw366
         fkQQ==
X-Gm-Message-State: APjAAAWKD1Ubu0/x5JnEex5t6XxLBFa9sISysP5l7QJD4viP+L7iO4j0
	XtkSZb5dprKM4+LW1zWCX99iJDUebjGZTibhlIQtETd1n/boUJ3rUFbF+jqP1z35A6cWpXgMvYD
	MRuXCxhHBo7H3ynl5USHOShmuaK5JLze4eWfi6vpR8crn9Y9l+3wsfjBYDj991/SwYA==
X-Received: by 2002:a63:394:: with SMTP id 142mr9536645pgd.43.1564014658054;
        Wed, 24 Jul 2019 17:30:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQ9UiJrKMv81+3c/tQxomOfvbYTw0eC264M5UnugnuhsOvlHncVNl/NyaY1Z4k+PuKCQBc
X-Received: by 2002:a63:394:: with SMTP id 142mr9536571pgd.43.1564014656837;
        Wed, 24 Jul 2019 17:30:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564014656; cv=none;
        d=google.com; s=arc-20160816;
        b=sSVFY11MCPQtxeKQAXa+qqi/x3wRG4x9JddrFCeXI4H4i7hdOBQHbfJYY91ZL/pj5k
         dzx0186DwoUGfi+bb7RPUiNjozXINRMvuwKMhDXYkpnSb/WAypGHQ2WhWXGPqKGZGrd9
         ZuZA+iWRLdS0f+/BNCI00KJqDVi7zgxE28T7y9xhsgHNNRUqe3M5D1MzVMK/5JpI5ATh
         FDwbUNpAQn1po0UdLgSS1x35ghmg0C3DtO6nNUpRf3vA3lhZXM01EBrH6hpm1YalWefj
         AiGHSAPYicbn2MEMJAM7r9CLHWeY8ZCtxMIqVXwqlRzPQ5bPsX+z1RiygtcCmwPq+OVw
         FNlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aXeA4WNumL8ce2q31xsEhnW9xNk+0Px0w7z/1Z2NZI4=;
        b=YG80T9bMvX3R85Gn0uCNXEQJbdDHT7zGMQ/nTScs+jcqDvypHDst+HckukJLpxJADS
         Q94Z1n0L8In4ykchPcQmhD2XMP0AefVCrHA3IU3oOLtU3qwhIaq5ajH2YvDP7Znr3NPb
         XnIMQXeBr2GBO6KDiHlCAyWeFQMNj23PuwfFeZlXO+P72A5/oEla5AI41aajihXfoUk2
         GiV4wE+qKk8Z/OnDH49VSmPp7wbOUNMerm8/cri6kDDipGgpgZeD2EI2VUt2O4Ws2iwG
         LynU+/KAA99dTSUNtBtBzT+lpkgS2xGJHWN52GZ//Me90wYj/TKLCBkeDtudUPq5XkZ4
         6/0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XsSfkiST;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x7si16356022plv.130.2019.07.24.17.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 17:30:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XsSfkiST;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 32E8821855;
	Thu, 25 Jul 2019 00:30:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564014656;
	bh=12WS/4Om2TNStFHs5hKFh7qsUFZkZxUvYAg1bOamyjI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=XsSfkiSTY8pPvgphMgbO8N1Jcg8Vdy37H2mo3Yh8JAlHw4yAj0okiI1w1J/JG7Qx1
	 i9ZQIUZmCGlLyyKDWX1WZd0Met6s3ayTvW+BDGIksIRQOMDWeR1+fsqIAQuZsKhZOg
	 /MZznO5io+GCjdgeYPUq8cDCTTzWXUmizMY4vuA0=
Date: Wed, 24 Jul 2019 17:30:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, kbuild-all@01.org,
 linux-mm@kvack.org
Subject: Re: [PATCH v2 2/3] mm: Introduce page_shift()
Message-Id: <20190724173055.d3c6993bfdad0f49f95b311c@linux-foundation.org>
In-Reply-To: <201907241853.yNQTrJWd%lkp@intel.com>
References: <20190721104612.19120-3-willy@infradead.org>
	<201907241853.yNQTrJWd%lkp@intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jul 2019 18:40:25 +0800 kbuild test robot <lkp@intel.com> wrote:

> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [cannot apply to v5.3-rc1 next-20190724]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Matthew-Wilcox/Make-working-with-compound-pages-easier/20190722-030555
> config: powerpc64-allyesconfig (attached as .config)
> compiler: powerpc64-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=powerpc64 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> Note: the linux-review/Matthew-Wilcox/Make-working-with-compound-pages-easier/20190722-030555 HEAD e1bb8b04ba8cf861b2610b0ae646ee49cb069568 builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings (new ones prefixed by >>):
> 
>    drivers/vfio/vfio_iommu_spapr_tce.c: In function 'tce_page_is_contained':
> >> drivers/vfio/vfio_iommu_spapr_tce.c:193:9: error: called object 'page_shift' is not a function or function pointer
>      return page_shift(compound_head(page)) >= page_shift;
>             ^~~~~~~~~~
>    drivers/vfio/vfio_iommu_spapr_tce.c:179:16: note: declared here
>       unsigned int page_shift)
>                    ^~~~~~~~~~

This?

--- a/drivers/vfio/vfio_iommu_spapr_tce.c~mm-introduce-page_shift-fix
+++ a/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -176,13 +176,13 @@ put_exit:
 }
 
 static bool tce_page_is_contained(struct mm_struct *mm, unsigned long hpa,
-		unsigned int page_shift)
+		unsigned int it_page_shift)
 {
 	struct page *page;
 	unsigned long size = 0;
 
-	if (mm_iommu_is_devmem(mm, hpa, page_shift, &size))
-		return size == (1UL << page_shift);
+	if (mm_iommu_is_devmem(mm, hpa, it_page_shift, &size))
+		return size == (1UL << it_page_shift);
 
 	page = pfn_to_page(hpa >> PAGE_SHIFT);
 	/*
@@ -190,7 +190,7 @@ static bool tce_page_is_contained(struct
 	 * a page we just found. Otherwise the hardware can get access to
 	 * a bigger memory chunk that it should.
 	 */
-	return page_shift(compound_head(page)) >= page_shift;
+	return page_shift(compound_head(page)) >= it_page_shift;
 }
 
 static inline bool tce_groups_attached(struct tce_container *container)
_

