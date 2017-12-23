Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 459616B0038
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 04:54:23 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l33so17756762wrl.5
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 01:54:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c22sor14351992eda.29.2017.12.23.01.54.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Dec 2017 01:54:22 -0800 (PST)
Date: Sat, 23 Dec 2017 12:54:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/sparse.c: Wrong allocation for mem_section
Message-ID: <20171223095419.73wtz3qyou675zfk@node.shutemov.name>
References: <1513932498-20350-1-git-send-email-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513932498-20350-1-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Atsushi Kumagai <ats-kumagai@wm.jp.nec.com>, linux-mm@kvack.org

On Fri, Dec 22, 2017 at 04:48:18PM +0800, Baoquan He wrote:
> In commit
> 
>   83e3c48729 "mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y"
> 
> mem_section is allocated at runtime to save memory. While it allocates
> the first dimension of array with sizeof(struct mem_section). It costs 
> extra memory, should be sizeof(struct mem_section*).
> 
> Fix it.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> Tested-by: Dave Young <dyoung@redhat.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Atsushi Kumagai <ats-kumagai@wm.jp.nec.com>
> Cc: linux-mm@kvack.org

Ughh. Sorry.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Please queue it to stable.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
