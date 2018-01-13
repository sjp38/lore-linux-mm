Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 945F16B0268
	for <linux-mm@kvack.org>; Sat, 13 Jan 2018 13:26:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d63so4287557wma.4
        for <linux-mm@kvack.org>; Sat, 13 Jan 2018 10:26:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g27sor13886433edf.52.2018.01.13.10.26.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Jan 2018 10:26:23 -0800 (PST)
Date: Sat, 13 Jan 2018 21:26:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] kdump: Write a correct address of mem_section into
 vmcoreinfo
Message-ID: <20180113182621.vypecadghlokdxta@node.shutemov.name>
References: <20180112162532.35896-1-kirill.shutemov@linux.intel.com>
 <20180113104838.ht57uooqk3fo546o@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180113104838.ht57uooqk3fo546o@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org, stable@vger.kernel.org

On Sat, Jan 13, 2018 at 11:48:38AM +0100, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > Depending on configuration mem_section can now be an array or a pointer
> > to an array allocated dynamically. In most cases, we can continue to refer
> > to it as 'mem_section' regardless of what it is.
> > 
> > But there's one exception: '&mem_section' means "address of the array" if
> > mem_section is an array, but if mem_section is a pointer, it would mean
> > "address of the pointer".
> > 
> > We've stepped onto this in kdump code. VMCOREINFO_SYMBOL(mem_section)
> > writes down address of pointer into vmcoreinfo, not array as we wanted.
> > 
> > Let's introduce VMCOREINFO_SYMBOL_ARRAY() that would handle the
> > situation correctly for both cases.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Fixes: 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y")
> > Cc: stable@vger.kernel.org
> > Acked-by: Baoquan He <bhe@redhat.com>
> > Acked-by: Dave Young <dyoung@redhat.com>
> 
> You forgot the Reported-by - I added that to the commit.

Oops, sorry.

Note, that Andrew has already pick it up and sent it upstream.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
