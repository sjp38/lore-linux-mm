Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0BFB6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 06:59:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id m65so6667088pfm.14
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 03:59:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e3si1021965pfi.191.2018.01.29.03.59.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jan 2018 03:59:35 -0800 (PST)
Date: Mon, 29 Jan 2018 03:59:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] x86/kexec: Make kexec work in 5-level paging mode
Message-ID: <20180129115927.GB18247@bombadil.infradead.org>
References: <20180129110845.26633-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129110845.26633-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 29, 2018 at 02:08:45PM +0300, Kirill A. Shutemov wrote:
> I've missed that we need to change relocate_kernel() to set CR4.LA57
> flag if the kernel has 5-level paging enabled.
> 
> I avoided to use ifdef CONFIG_X86_5LEVEL here and inferred if we need to
> enabled 5-level paging from previous CR4 value. This way the code is
> ready for boot-time switching between paging modes.

Forgive me if I'm missing something ... can you kexec a 5-level kernel
from a 4-level kernel or vice versa?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
