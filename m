Return-Path: <SRS0=4eAG=W4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA768C3A5A8
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 18:45:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B2E72190F
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 18:45:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="T5XyQ/Kg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B2E72190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC0516B000A; Sun,  1 Sep 2019 14:45:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E70F46B000C; Sun,  1 Sep 2019 14:45:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D86966B000D; Sun,  1 Sep 2019 14:45:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id B83F06B000A
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 14:45:34 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 427A052DB
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 18:45:34 +0000 (UTC)
X-FDA: 75887230188.04.copy30_4dad01af75e4b
X-HE-Tag: copy30_4dad01af75e4b
X-Filterd-Recvd-Size: 6682
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 18:45:33 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id h195so1029226pfe.5
        for <linux-mm@kvack.org>; Sun, 01 Sep 2019 11:45:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fqfQWMarMdDkfbNOn4WI4sbX6dM4CfWKPVMS23oSdX0=;
        b=T5XyQ/KgzWajnkiQytJqYa+AvUv9dMJMBPxCnPHvYDTXwC1N7aC4fzYF9ju5sjkpMr
         4C8xRoHmEvl/nSRteWeYTSTb3qKKQFLJ3AnrFu/uUTkZzPoqD1Qkr3BFZf+qzdJ+z1kG
         vXdpJxKK6PaaqTqxepIgXLZVOG/0ZSyUGE/mWOzHxkqAhbvCfikOTEBNlSLIuJzsbgAV
         KVdYER6Y+p1RodFeJlyWmRmte1xC/0vGZ7HRKtn5QsOYB/070B3ccYbrvl6OBI/OSj38
         lEeslnOVQjkPbm2B95NK6E/NmTyeFgIonoazNSc8czWTS9rPVid7B3w3ne9bOsrnX9E1
         Tk1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=fqfQWMarMdDkfbNOn4WI4sbX6dM4CfWKPVMS23oSdX0=;
        b=K+Ca9mXLrcqDuuT1Vryrkw+4iQzQRCzbwBsDCcBZchEkIC2REl9ri6jvgIIzNTWUm9
         IEQ9i1DLQCs6v5CcOBZOgXmG2iKfkIyI9uJYZ/QSJ5ByBuLlMvc5ItbRJfD9VPqxNBfy
         7nhaLEUglEt9RCIoZnvk5+TxZRejXg4dzGAFFaWcW7YKXHkeChfCOjM2WFOiNhBNOtdA
         97Ocr4vQr68kysgECZggukNwwDLRbi1JtE4lu33EnM581fdutXcY96/7lXva7e/KTNHo
         gTebdRf5fhr2yzWGfYa+yiJTeGzMphxs8kSMKYQkPBdGOR6MnUrBjKWGbmc258bpw/n7
         vufQ==
X-Gm-Message-State: APjAAAUnha7+qS2+YiMrUDiBQe0o/mdio3PcwG/esV8r0gvqaUjg+V89
	bvrQCfFySkEkbsJGOHXrsOo=
X-Google-Smtp-Source: APXvYqyUn3CzFDVNpZaQhYFS85Ba9bnislPhbAOl0IsGT2tb3lJDEI1z8vjYa4BHwrj8wX2vedTiaA==
X-Received: by 2002:a63:ff66:: with SMTP id s38mr22462034pgk.363.1567363532659;
        Sun, 01 Sep 2019 11:45:32 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id j1sm10827106pgl.12.2019.09.01.11.45.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Sep 2019 11:45:31 -0700 (PDT)
Date: Sun, 1 Sep 2019 11:45:30 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Thomas Hellstrom <thellstrom@vmware.com>
Subject: Re: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Message-ID: <20190901184530.GA18656@roeck-us.net>
References: <20190828141955.22210-1-hch@lst.de>
 <20190828141955.22210-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190828141955.22210-3-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 04:19:54PM +0200, Christoph Hellwig wrote:
> The mm_walk structure currently mixed data and code.  Split out the
> operations vectors into a new mm_walk_ops structure, and while we
> are changing the API also declare the mm_walk structure inside the
> walk_page_range and walk_page_vma functions.
> 
> Based on patch from Linus Torvalds.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
> Reviewed-by: Steven Price <steven.price@arm.com>
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

When building csky:defconfig:

In file included from mm/madvise.c:30:
mm/madvise.c: In function 'madvise_free_single_vma':
arch/csky/include/asm/tlb.h:11:11: error:
	invalid type argument of '->' (have 'struct mmu_gather')

Guenter

---
# bad: [6d028043b55e54f48fbdf62ea8ce11a4ad830cac] Add linux-next specific files for 20190830
# good: [a55aa89aab90fae7c815b0551b07be37db359d76] Linux 5.3-rc6
git bisect start 'HEAD' 'v5.3-rc6'
# good: [199d454c0775386a645dd9e80b486c346816762f] Merge remote-tracking branch 'crypto/master'
git bisect good 199d454c0775386a645dd9e80b486c346816762f
# good: [450fd5809930dfee10dbbf351cdb2148cd022b1c] Merge remote-tracking branch 'regulator/for-next'
git bisect good 450fd5809930dfee10dbbf351cdb2148cd022b1c
# good: [12b85c8517393b5466dff225a338fc7416150df0] Merge remote-tracking branch 'tty/tty-next'
git bisect good 12b85c8517393b5466dff225a338fc7416150df0
# good: [ecda3e90e6357b15f3189ce00938ea5a20850b76] Merge remote-tracking branch 'scsi/for-next'
git bisect good ecda3e90e6357b15f3189ce00938ea5a20850b76
# good: [4cb65f973115d07578f5b8f4492da7d8295effe2] Merge remote-tracking branch 'rtc/rtc-next'
git bisect good 4cb65f973115d07578f5b8f4492da7d8295effe2
# good: [f3bf5fa4097e06b9cabb193599a012680380e52e] kernel/elfcore.c: include proper prototypes
git bisect good f3bf5fa4097e06b9cabb193599a012680380e52e
# bad: [e58b341134ca751d9c12bacded12a8b4dd51368d] Merge remote-tracking branch 'hmm/hmm'
git bisect bad e58b341134ca751d9c12bacded12a8b4dd51368d
# good: [47f725ee7b5f5cae1f83512961bcf8b41a7a5794] RDMA/odp: remove ib_ucontext from ib_umem
git bisect good 47f725ee7b5f5cae1f83512961bcf8b41a7a5794
# good: [f9016e8058fdcd4aadc9932e045891a7b3bc8c8f] Merge remote-tracking branch 'nvmem/for-next'
git bisect good f9016e8058fdcd4aadc9932e045891a7b3bc8c8f
# good: [2f6e2a06b51e0dd9767bf37c3542ee3b5e4611d4] Merge remote-tracking branch 'pidfd/for-next'
git bisect good 2f6e2a06b51e0dd9767bf37c3542ee3b5e4611d4
# good: [d2b219ed03d45a9799e4ba780c209edf9c510d3b] mm/mmu_notifiers: add a lockdep map for invalidate_range_start/end
git bisect good d2b219ed03d45a9799e4ba780c209edf9c510d3b
# good: [4e10e8c36663a011f77d39c937aaa473fad90de3] mm: split out a new pagewalk.h header from mm.h
git bisect good 4e10e8c36663a011f77d39c937aaa473fad90de3
# bad: [5b8f3df6239c3a9b625ab4bdc69c54d4768a4f06] pagewalk: use lockdep_assert_held for locking validation
git bisect bad 5b8f3df6239c3a9b625ab4bdc69c54d4768a4f06
# bad: [923bfc561e7535f7dc2be136da75690582268cf2] pagewalk: separate function pointers from iterator data
git bisect bad 923bfc561e7535f7dc2be136da75690582268cf2
# first bad commit: [923bfc561e7535f7dc2be136da75690582268cf2] pagewalk: separate function pointers from iterator data

