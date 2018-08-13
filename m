Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B91956B0007
	for <linux-mm@kvack.org>; Sun, 12 Aug 2018 22:30:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f66-v6so4356378plb.10
        for <linux-mm@kvack.org>; Sun, 12 Aug 2018 19:30:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r11-v6si14339799plo.144.2018.08.12.19.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 12 Aug 2018 19:30:20 -0700 (PDT)
Date: Sun, 12 Aug 2018 19:30:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: memblock:What is the difference between memory and physmem?
Message-ID: <20180813023015.GB32733@bombadil.infradead.org>
References: <80B78A8B8FEE6145A87579E8435D78C3240515EF@FZEX4.ruijie.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80B78A8B8FEE6145A87579E8435D78C3240515EF@FZEX4.ruijie.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yhb@ruijie.com.cn
Cc: linux-mm@kvack.org

On Mon, Aug 13, 2018 at 02:23:26AM +0000, yhb@ruijie.com.cn wrote:
> struct memblock {
> bool bottom_up; /* is bottom up direction? */
> phys_addr_t current_limit;
> struct memblock_type memory;
> struct memblock_type reserved;
> #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> struct memblock_type physmem;
> #endif
> };
> What is the difference between memory and physmem?

commit 70210ed950b538ee7eb811dccc402db9df1c9be4
Author: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Date:   Wed Jan 29 18:16:01 2014 +0100

    mm/memblock: add physical memory list
    
    Add the physmem list to the memblock structure. This list only exists
    if HAVE_MEMBLOCK_PHYS_MAP is selected and contains the unmodified
    list of physically available memory. It differs from the memblock
    memory list as it always contains all memory ranges even if the
    memory has been restricted, e.g. by use of the mem= kernel parameter.
    
    Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
    Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
