Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD70A6B029C
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:05:08 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r20-v6so4055232pgv.20
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 05:05:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w15-v6si13029751pga.30.2018.07.25.05.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Jul 2018 05:05:07 -0700 (PDT)
Date: Wed, 25 Jul 2018 05:05:00 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 5/7] docs/core-api: split memory management API to a
 separate file
Message-ID: <20180725120500.GA9352@bombadil.infradead.org>
References: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1532517970-16409-6-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532517970-16409-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 25, 2018 at 02:26:08PM +0300, Mike Rapoport wrote:
> +User Space Memory Access
> +========================
> +
> +.. kernel-doc:: arch/x86/include/asm/uaccess.h
> +   :internal:
> +
> +.. kernel-doc:: arch/x86/lib/usercopy_32.c
> +   :export:
> +
> +The Slab Cache
> +==============
> +
> +.. kernel-doc:: include/linux/slab.h
> +   :internal:
> +
> +.. kernel-doc:: mm/slab.c
> +   :export:
> +
> +.. kernel-doc:: mm/util.c
> +   :functions: kfree_const kvmalloc_node kvfree get_user_pages_fast

get_user_pages_fast would fit better in the previous 'User Space Memory
Access' section.
