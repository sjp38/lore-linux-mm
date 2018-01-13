Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 300F96B025F
	for <linux-mm@kvack.org>; Sat, 13 Jan 2018 05:48:49 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id p4so5001643wrf.4
        for <linux-mm@kvack.org>; Sat, 13 Jan 2018 02:48:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3sor1774269wre.21.2018.01.13.02.48.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Jan 2018 02:48:47 -0800 (PST)
Date: Sat, 13 Jan 2018 11:48:38 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] kdump: Write a correct address of mem_section into
 vmcoreinfo
Message-ID: <20180113104838.ht57uooqk3fo546o@gmail.com>
References: <20180112162532.35896-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180112162532.35896-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org, stable@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> Depending on configuration mem_section can now be an array or a pointer
> to an array allocated dynamically. In most cases, we can continue to refer
> to it as 'mem_section' regardless of what it is.
> 
> But there's one exception: '&mem_section' means "address of the array" if
> mem_section is an array, but if mem_section is a pointer, it would mean
> "address of the pointer".
> 
> We've stepped onto this in kdump code. VMCOREINFO_SYMBOL(mem_section)
> writes down address of pointer into vmcoreinfo, not array as we wanted.
> 
> Let's introduce VMCOREINFO_SYMBOL_ARRAY() that would handle the
> situation correctly for both cases.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y")
> Cc: stable@vger.kernel.org
> Acked-by: Baoquan He <bhe@redhat.com>
> Acked-by: Dave Young <dyoung@redhat.com>

You forgot the Reported-by - I added that to the commit.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
