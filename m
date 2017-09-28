Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7553D6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:07:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e195so980432wma.6
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:07:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l101sor360071wrc.16.2017.09.28.01.07.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:07:14 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:07:11 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 01/19] mm/sparsemem: Allocate mem_section at runtime
 for SPARSEMEM_EXTREME
Message-ID: <20170928080711.3msbrmwluqwfhjkg@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> Size of mem_section array depends on size of physical address space.
> 
> In preparation for boot-time switching between paging modes on x86-64
> we need to make allocation of mem_section dynamic.
> 
> The patch allocates the array on the first call to
> sparse_memory_present_with_active_regions().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

What is the size of the allocations here, in bytes, for the two main variants?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
