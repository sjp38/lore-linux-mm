Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5731A6B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 19:23:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b11-v6so13254740pla.19
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 16:23:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f7si12351786pgn.476.2018.04.17.16.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 16:22:59 -0700 (PDT)
Date: Tue, 17 Apr 2018 16:22:48 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
Message-ID: <20180417232248.GA27631@bombadil.infradead.org>
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: viro@zeniv.linux.org.uk, nyc@holomorphy.com, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 18, 2018 at 05:08:13AM +0800, Yang Shi wrote:
> When applications use huge page on hugetlbfs, it just need check the
> filesystem magic number, but it is not enough for tmpfs. So, introduce
> ST_HUGE flag to statfs if super block has SB_HUGE set which indicates
> huge page is supported on the specific filesystem.

Hm.  What's the plan for communicating support for page sizes other
than PMD page sizes?  I know ARM has several different page sizes,
as do PA-RISC and ia64.  Even x86 might support 1G page sizes through
tmpfs one day.
