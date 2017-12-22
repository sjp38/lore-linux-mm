Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F03D36B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 10:03:27 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l33so16741620wrl.5
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 07:03:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f16si10558038wrf.172.2017.12.22.07.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 07:03:26 -0800 (PST)
Date: Fri, 22 Dec 2017 16:03:26 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20171222150326.GC28720@kroah.com>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <20171222141810.dpeozmylmnj253do@xps>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222141810.dpeozmylmnj253do@xps>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Fri, Dec 22, 2017 at 08:18:10AM -0600, Dan Rue wrote:
> On Fri, Dec 22, 2017 at 09:45:08AM +0100, Greg Kroah-Hartman wrote:
> > 4.14-stable review patch.  If anyone has any objections, please let me know.
> > 
> > ------------------
> > 
> > From: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > 
> > commit 83e3c48729d9ebb7af5a31a504f3fd6aff0348c4 upstream.
> > 
> > Size of the mem_section[] array depends on the size of the physical address space.
> > 
> > In preparation for boot-time switching between paging modes on x86-64
> > we need to make the allocation of mem_section[] dynamic, because otherwise
> > we waste a lot of RAM: with CONFIG_NODE_SHIFT=10, mem_section[] size is 32kB
> > for 4-level paging and 2MB for 5-level paging mode.
> > 
> > The patch allocates the array on the first call to sparse_memory_present_with_active_regions().
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Andy Lutomirski <luto@amacapital.net>
> > Cc: Borislav Petkov <bp@suse.de>
> > Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: linux-mm@kvack.org
> > Link: http://lkml.kernel.org/r/20170929140821.37654-2-kirill.shutemov@linux.intel.com
> > Signed-off-by: Ingo Molnar <mingo@kernel.org>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> 
> This patch causes a boot failure on arm64.
> 
> Please drop this patch, or pick up the fix in:
> 
>     commit 629a359bdb0e0652a8227b4ff3125431995fec6e
>     Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>     Date:   Tue Nov 7 11:33:37 2017 +0300
> 
>         mm/sparsemem: Fix ARM64 boot crash when CONFIG_SPARSEMEM_EXTREME=y
> 
> See https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1527427.html

Now added, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
