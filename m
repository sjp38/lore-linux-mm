Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBED6B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 09:06:12 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id s23-v6so3045056plr.15
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 06:06:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v32-v6si5749194plb.575.2018.04.01.06.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 01 Apr 2018 06:06:08 -0700 (PDT)
Date: Sun, 1 Apr 2018 06:06:07 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Why the kernel needs `split_mem_range` to split the physical
 address range?
Message-ID: <20180401130607.GG13332@bombadil.infradead.org>
References: <CA+PpKPnOn9GLSfHUCNPSqLQUs0ySN_oCLDmBA_KG59iEpcS71Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+PpKPnOn9GLSfHUCNPSqLQUs0ySN_oCLDmBA_KG59iEpcS71Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hao Lee <haolee.swjtu@gmail.com>
Cc: linux-mm@kvack.org

On Sun, Apr 01, 2018 at 03:01:13PM +0800, Hao Lee wrote:
> I wonder why the kernel needs `split_mem_range()`[0] to split physical
> address range. To make this question clear, I find an example from
> dmesg. The arguments of `split_mem_range` are start=0x00100000,
> end=0x80000000. The splitting result is:
> 
> [mem 0x00100000-0x001FFFFF] page 4k
> [mem 0x00200000-0x7FFFFFFF] page 2M
> 
> I don't know why the first 1MiB range is separated out to use 4k page
> frame. I think these two ranges can be merged and let the range
> [0x00100000-0x7FFFFFFF] use 2M page frame completely. I can't
> understand the purpose of this range splitting. Could someone please
> explain this function to me? Many Thanks!

2MB pages have to be 2MB aligned.  If you want to use the memory between
1MB and 2MB, but not the memory between 0MB and 1MB, you must split the
first 2MB range into 4kB pages.
