Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D497B6B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 06:52:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q126so21995715pga.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:52:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w67si1661468pfd.29.2017.03.24.03.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 03:52:00 -0700 (PDT)
Date: Fri, 24 Mar 2017 11:51:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [x86/mm/gup] 2947ba054a [   71.329069] kernel BUG at
 include/linux/pagemap.h:151!
Message-ID: <20170324105153.xvy5rcuawicqoanl@hirez.programming.kicks-ass.net>
References: <20170319225124.xodpqjldom6ceazz@wfg-t540p.sh.intel.com>
 <20170324102436.xltop6udkx5pg4oq@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170324102436.xltop6udkx5pg4oq@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@kernel.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Fengguang Wu <fengguang.wu@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, LKP <lkp@01.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Fri, Mar 24, 2017 at 01:24:36PM +0300, Kirill A. Shutemov wrote:

> I'm not sure what is the best way to fix this.
> Few options:
>  - Drop the VM_BUG();
>  - Bump preempt count during __get_user_pages_fast();
>  - Use get_page() instead of page_cache_get_speculative() on x86.
> 
> Any opinions?

I think I'm in favour of the first; either remove or amend to include
irqs_disabled() or so.

This in favour of keeping the variants of GUP down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
