Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 073CE6B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 04:21:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c56-v6so14246941wrc.5
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 01:21:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s6sor2797121edq.32.2018.04.22.01.21.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 01:21:33 -0700 (PDT)
Date: Thu, 19 Apr 2018 12:05:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
Message-ID: <20180419090512.apnalks6s5z63lqq@node.shutemov.name>
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180418102744.GA10397@infradead.org>
 <73090d4b-6831-805b-8b9d-5dff267428d9@linux.alibaba.com>
 <20180419082810.GA8624@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419082810.GA8624@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, viro@zeniv.linux.org.uk, nyc@holomorphy.com, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 19, 2018 at 01:28:10AM -0700, Christoph Hellwig wrote:
> On Wed, Apr 18, 2018 at 11:18:25AM -0700, Yang Shi wrote:
> > Yes, thanks for the suggestion. I did think about it before I went with the
> > new flag. Not like hugetlb, THP will *not* guarantee huge page is used all
> > the time, it may fallback to regular 4K page or may get split. I'm not sure
> > how the applications use f_bsize field, it might break existing applications
> > and the value might be abused by applications to have counter optimization.
> > So, IMHO, a new flag may sound safer.
> 
> But st_blksize isn't the block size, that is why I suggested it.  It is
> the preferred I/O size, and various file systems can report way
> larger values than the block size already.

I agree. This looks like a better fit.

-- 
 Kirill A. Shutemov
