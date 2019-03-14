Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC474C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:01:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74D072184E
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:01:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GD8Z4IVc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74D072184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15D008E0003; Thu, 14 Mar 2019 12:01:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E4148E0001; Thu, 14 Mar 2019 12:01:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC8038E0003; Thu, 14 Mar 2019 12:00:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA66D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:00:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w4so6656695pgl.19
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:00:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0BRZmjWpl5Sc1xK8Fz95Tal8y+zU630oI+RCC6+Hs4Q=;
        b=L46pnxMri6mVjHoT+GlDcY6lT4knfbCfntuJoL+k7Aw1znYlyJA78GcUq87wG1Zr47
         reoERY3AnXr56v1yLDprMJiZFbjAqRGSYlF6C4OOo0D9D7yjIf6GpJXi17P/xFqkLvma
         d0OIfWKvXwBByjMbxTRunbm87LSFW6Mda62FRCPJc+locUtG33CQomactBRSo2DLr1DZ
         nI9gYRXaiNGALbK+yayw+JqiHZxV+yReA3PFuMY+8zTbzqVmqiTtay7WT/8d019LMaLi
         o6xRz0p3S/eREfVytPeqRJ8guD6b3TRRmiQZon2xxh3Y0rIH00kR39NxTMP/fIL2sdUQ
         1dfA==
X-Gm-Message-State: APjAAAUgHjs2HcLUQR4p08IAluTSINlzaEBrEz/6+cLY1wP53Gfn+JBY
	BPrp/TsvMZE7eoIYNEJ+HRnzsCl364U0J8pKCZpITaPm7Z6wwqOUxU9/4dfmtu8RI3TDwhaWizF
	uYJuap48KEXMeAZKhiUZRww0TM9Y34aHuvUe0L586FYr8wzjtiLm7SVBRLxOgmHxCIA==
X-Received: by 2002:a62:484:: with SMTP id 126mr49654940pfe.91.1552579259404;
        Thu, 14 Mar 2019 09:00:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDvfV964EDUFCYrfVb8xXACoJLLaOTk83mXvksT8NCl2q3hkmKLOIoFTFnZGYUABjVdgLT
X-Received: by 2002:a62:484:: with SMTP id 126mr49654857pfe.91.1552579258566;
        Thu, 14 Mar 2019 09:00:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552579258; cv=none;
        d=google.com; s=arc-20160816;
        b=so9MKxlez/VDOQfi1lTkjKyvg92fCVJ9QlFN02+XJvlr9KMf+Rsjwi3BagGb6XuK7m
         IDNTvGruwIuo0kqgxFFQniJ5HWC56m1Oc7jmp3D3qI39U1ujkIz3ReGHLDxT/OTOmPmo
         l7GKyxXGV6tzOXx6g7OlIZL5pYQ7icH8ceMSvbtXGr/mbA6/vFc6V2H5GWjCyw+C4qJe
         nsPCvyYtNi1TnO4KUKHEt8hArNkBUndDKPZvmemrZPcYWARCDBfyq+0PygeZqBpdbsYO
         fmLbMiFdOSON/glXpgrcP7vUo1qiTjQ5fAmCSfc25mG+Hf5YJevRTvn8p+RgZPoFZ4hT
         kUvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0BRZmjWpl5Sc1xK8Fz95Tal8y+zU630oI+RCC6+Hs4Q=;
        b=udllYnmAzj77tGh++Uy85udurxAitnkBcFI5Rxkn5w7sH9pb5SMGhScCpqHHAfyRue
         TkioMkNRo1lhrhnMQdSHYAI/5JNes3vCKkO6GnMPRuRstsf76AQ+ATO1hqLGYCmFy8MW
         S6ht95D/THF0qBuUqL6DXQTawi1zjhxP8qtWmpz9SkZiq9ivvY8SuALYoprgVu7TDjJW
         CGObTK++zQz8TQJq7823zyxfzVNcS9qB3cmt2i+OUEZTOy65rhlpp58jiwZQ1O89gc0F
         3wSH/HfLobqHB2DKCCPxDxIY/N7Cg7wlGnz5qPNi5V0zZLEFJV71FYV6BG9O9IarMxSS
         Miwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GD8Z4IVc;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d11si13778828pls.255.2019.03.14.09.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Mar 2019 09:00:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GD8Z4IVc;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=0BRZmjWpl5Sc1xK8Fz95Tal8y+zU630oI+RCC6+Hs4Q=; b=GD8Z4IVcQkEnA7tmQZRmDMsZD
	acod4OPFsUrsOfuR1FLKJ7jA6erX0GyfzkAUFalRqQTr0Wc3TKoZdJNJn8bnGOw1Tuwdk0yZnf64/
	pHdMOlRrDmx/7IEqQ2GJCttrttVDEbZnPlnVXa/Qa5+V4mhw8zHKfWPeKpTViw6WFl+GFz/H2TmaG
	4qFtmgaq3A/Nx1q4BNCMbmX10cEE5rq+9ERqls/hf1LDnS18ontilivt/3dX71VKoTcfON3Jd9RIv
	iAQfJKRmrX3ZqBsjJswgiXTngc2vG+33cgA8AIHPVWsNtlDueAJM3S6t3N16/Dfynz5q0V1zwwby5
	vq3znBuDQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h4Smr-0005gI-10; Thu, 14 Mar 2019 16:00:53 +0000
Date: Thu, 14 Mar 2019 09:00:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	linux-kernel@vger.kernel.org,
	William Kucharski <william.kucharski@oracle.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: mm/memory.c:3968:21: sparse: incorrect type in assignment
 (different base types)
Message-ID: <20190314160052.GM19508@bombadil.infradead.org>
References: <201903140301.VeDCo2VR%lkp@intel.com>
 <CAFqt6zaA1t1+vPL8hk7Rm6B4ZqG6maK+Z1HAkL0aF93=q4MeOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zaA1t1+vPL8hk7Rm6B4ZqG6maK+Z1HAkL0aF93=q4MeOQ@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 03:10:19PM +0530, Souptick Joarder wrote:
> > >> mm/memory.c:3968:21: sparse: incorrect type in assignment (different base types) @@    expected restricted vm_fault_t [usertype] ret @@    got e] ret @@
> >    mm/memory.c:3968:21:    expected restricted vm_fault_t [usertype] ret
> >    mm/memory.c:3968:21:    got int
> 
> Looking into https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> hugetlb_fault() is converted to return vm_fault_t. Not sure, why sparse is
> still throwing warnings.

Because there are two definitions of hugetlb_fault():

$ git grep -wn hugetlb_fault
include/linux/hugetlb.h:108:vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
include/linux/hugetlb.h:206:#define hugetlb_fault(mm, vma, addr, flags) ({ BUG(); 0; })


