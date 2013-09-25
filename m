Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 05D956B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 05:24:06 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so6240045pad.14
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 02:24:06 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CACz4_2drFs5LsM8mTFNOWGHAs0QbsNfHAhiBXJ7jM3qkGerd5w@mail.gmail.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CACz4_2drFs5LsM8mTFNOWGHAs0QbsNfHAhiBXJ7jM3qkGerd5w@mail.gmail.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Content-Transfer-Encoding: 7bit
Message-Id: <20130925092355.E785EE0090@blue.fi.intel.com>
Date: Wed, 25 Sep 2013 12:23:55 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> Hi, Kirill,
> 
> Seems you dropped one patch in v5, is that intentional? Just wondering ...
> 
>   thp, mm: handle tail pages in page_cache_get_speculative()

It's not needed anymore, since we don't have tail pages in radix tree.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
