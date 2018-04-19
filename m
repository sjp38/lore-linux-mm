Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 067DF6B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:28:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so2397133pfz.19
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 01:28:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g67si2819102pfk.90.2018.04.19.01.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Apr 2018 01:28:20 -0700 (PDT)
Date: Thu, 19 Apr 2018 01:28:10 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
Message-ID: <20180419082810.GA8624@infradead.org>
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180418102744.GA10397@infradead.org>
 <73090d4b-6831-805b-8b9d-5dff267428d9@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <73090d4b-6831-805b-8b9d-5dff267428d9@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk, nyc@holomorphy.com, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 18, 2018 at 11:18:25AM -0700, Yang Shi wrote:
> Yes, thanks for the suggestion. I did think about it before I went with the
> new flag. Not like hugetlb, THP will *not* guarantee huge page is used all
> the time, it may fallback to regular 4K page or may get split. I'm not sure
> how the applications use f_bsize field, it might break existing applications
> and the value might be abused by applications to have counter optimization.
> So, IMHO, a new flag may sound safer.

But st_blksize isn't the block size, that is why I suggested it.  It is
the preferred I/O size, and various file systems can report way
larger values than the block size already.
