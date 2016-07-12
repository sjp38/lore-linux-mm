Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4725E6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:33:19 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id wu1so30415872obb.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:33:19 -0700 (PDT)
Received: from szxga04-in.huawei.com ([58.251.152.52])
        by mx.google.com with ESMTPS id y10si490375oia.230.2016.07.12.06.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 06:33:18 -0700 (PDT)
Message-ID: <5784ED97.1080807@huawei.com>
Date: Tue, 12 Jul 2016 21:16:07 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: why not add __GFP_HIGHMEM directly in alloc_migrate_target()?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

alloc_migrate_target() is called from migrate_pages(),
so the page is always from user space, so why not add
__GFP_HIGHMEM directly, instead of the following code.

	if (PageHighMem(page))  // it always return false in x86_64
		gfp_mask |= __GFP_HIGHMEM;


Another question, when we do migration, why should split THP
first?
e.g. 2M(512*4kb) should flush 512 times TLB, and 2M(2M*1) only need one. 
I find flush TLB takes a lot of time, especially multithreaded app.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
