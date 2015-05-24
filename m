Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3726B007D
	for <linux-mm@kvack.org>; Sun, 24 May 2015 13:49:10 -0400 (EDT)
Received: by wibt6 with SMTP id t6so30441355wib.0
        for <linux-mm@kvack.org>; Sun, 24 May 2015 10:49:09 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id cn6si14262623wjb.209.2015.05.24.10.49.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 May 2015 10:49:08 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Date: Sun, 24 May 2015 19:49:01 +0200
Message-ID: <5992243.NYDGjLH37z@wuerfel>
In-Reply-To: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Jungseok Lee <jungseoklee85@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, barami97@gmail.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Monday 25 May 2015 01:02:20 Jungseok Lee wrote:
> Fork-routine sometimes fails to get a physically contiguous region for
> thread_info on 4KB page system although free memory is enough. That is,
> a physically contiguous region, which is currently 16KB, is not available
> since system memory is fragmented.
> 
> This patch tries to solve the problem as allocating thread_info memory
> from vmalloc space, not 1:1 mapping one. The downside is one additional
> page allocation in case of vmalloc. However, vmalloc space is large enough,
> around 240GB, under a combination of 39-bit VA and 4KB page. Thus, it is
> not a big tradeoff for fork-routine service.

vmalloc has a rather large runtime cost. I'd argue that failing to allocate
thread_info structures means something has gone very wrong.

Can you describe the scenario that leads to fragmentation this bad?

Could the stack size be reduced to 8KB perhaps?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
