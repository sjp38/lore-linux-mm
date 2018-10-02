Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4C96B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 03:54:08 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m3-v6so576616plt.9
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 00:54:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor4392849pld.49.2018.10.02.00.54.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 00:54:07 -0700 (PDT)
Date: Tue, 2 Oct 2018 16:54:02 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: Avoid swapping in interrupt context
Message-ID: <20181002075402.GI598@jagdpanzerIV>
References: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Mhetre <amhetre@nvidia.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com, Sri Krishna chowdary <schowdary@nvidia.com>

On (10/01/18 15:15), Ashish Mhetre wrote:
> From: Sri Krishna chowdary <schowdary@nvidia.com>
> 
> Pages can be swapped out from interrupt context as well.

Well, if you do kmalloc(GFP_KERNEL) from IRQ then that's the bug
you need to fix in the first place.

> ZRAM uses zsmalloc allocator to make room for these pages.
> 
> But zsmalloc is not made to be used from interrupt context.
> This can result in a kernel Oops.

Most like not just "can" but "will" result in panic(). We have
BUG_ON(in_interrupt()) in zsmalloc.

	-ss
