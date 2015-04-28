Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 869836B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:14:23 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so8375673pac.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:14:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k5si36571919pdl.3.2015.04.28.15.14.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:14:22 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:14:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] compaction: fix isolate_migratepages_block() for THP=n
Message-Id: <20150428151420.227e7ac34745e9fe8e9bc145@linux-foundation.org>
In-Reply-To: <1430134006-215317-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1430134006-215317-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 27 Apr 2015 14:26:46 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> PageTrans* helpers are always-false if THP is disabled compile-time.
> It means the fucntion will fail to detect hugetlb pages in this case.
> 
> Let's use PageCompound() instead. With small tweak to how we calculate
> next low_pfn it will make function ready to see tail pages.

<scratches head>

So this patch has no runtime effects at present?  It is preparation for
something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
