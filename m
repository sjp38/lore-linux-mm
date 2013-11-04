Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DE8ED6B0036
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 05:43:09 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so6896228pab.0
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 02:43:09 -0800 (PST)
Received: from psmtp.com ([74.125.245.170])
        by mx.google.com with SMTP id gv2si10141874pbb.281.2013.11.04.02.43.03
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 02:43:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH] mm: create a separate slab for page->ptl allocation
Content-Transfer-Encoding: 7bit
Message-Id: <20131104104259.86AFEE0090@blue.fi.intel.com>
Date: Mon,  4 Nov 2013 12:42:59 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Kirill A. Shutemov wrote:
> If DEBUG_SPINLOCK and DEBUG_LOCK_ALLOC are enabled spinlock_t on x86_64
> is 72 bytes. For page->ptl they will be allocated from kmalloc-96 slab,
> so we loose 24 on each. An average system can easily allocate few tens
> thousands of page->ptl and overhead is significant.
> 
> Let's create a separate slab for page->ptl allocation to solve this.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

ping?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
