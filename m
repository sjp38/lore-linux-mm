Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5016B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 05:08:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d6so1440055wrd.7
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 02:08:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r12sor704781edb.17.2017.09.28.02.08.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 02:08:53 -0700 (PDT)
Date: Thu, 28 Sep 2017 12:08:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv7 01/19] mm/sparsemem: Allocate mem_section at runtime
 for SPARSEMEM_EXTREME
Message-ID: <20170928090850.oed4ls6ojpbjpkcp@node.shutemov.name>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-2-kirill.shutemov@linux.intel.com>
 <20170928080711.3msbrmwluqwfhjkg@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170928080711.3msbrmwluqwfhjkg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 28, 2017 at 10:07:11AM +0200, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > Size of mem_section array depends on size of physical address space.
> > 
> > In preparation for boot-time switching between paging modes on x86-64
> > we need to make allocation of mem_section dynamic.
> > 
> > The patch allocates the array on the first call to
> > sparse_memory_present_with_active_regions().
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> What is the size of the allocations here, in bytes, for the two main variants?

For 4-level paging it's 32k. For 5-level paging it's 2M.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
