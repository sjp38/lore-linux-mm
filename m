Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92C116B0006
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 13:58:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r20-v6so4840693pgv.20
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 10:58:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 192-v6si11655372pfa.81.2018.08.10.10.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 Aug 2018 10:58:04 -0700 (PDT)
Date: Fri, 10 Aug 2018 10:57:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v7 PATCH 2/4] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180810175759.GB6487@bombadil.infradead.org>
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-3-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533857763-43527-3-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 10, 2018 at 07:36:01AM +0800, Yang Shi wrote:
> +/*
> + * Zap pages with read mmap_sem held
> + *
> + * uf is the list for userfaultfd
> + */
> +static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
> +			       size_t len, struct list_head *uf)

I don't like the name here.  We aren't zapping rlocks, we're zapping
pages.  Not sure what to call it though ...
