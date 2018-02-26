Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4406B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 17:31:03 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id h33so1136925wrh.10
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 14:31:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q22si5230096wmf.112.2018.02.26.14.31.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 14:31:01 -0800 (PST)
Date: Mon, 26 Feb 2018 23:30:38 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH 2/5] x86/boot/compressed/64: Find a place for 32-bit
 trampoline
Message-ID: <20180226223038.GI14140@pd.tnic>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
 <20180226180451.86788-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180226180451.86788-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 26, 2018 at 09:04:48PM +0300, Kirill A. Shutemov wrote:
> +++ b/arch/x86/boot/compressed/pgtable.h
> @@ -0,0 +1,11 @@
> +#ifndef BOOT_COMPRESSED_PAGETABLE_H
> +#define BOOT_COMPRESSED_PAGETABLE_H
> +
> +#define TRAMPOLINE_32BIT_SIZE		(2 * PAGE_SIZE)
> +
> +#ifndef __ASSEMBLER__

x86 uses __ASSEMBLY__ everywhere and I see

arch/x86/boot/compressed/Makefile:41:KBUILD_AFLAGS  := $(KBUILD_CFLAGS) -D__ASSEMBLY__

so it should work here too.

Even though __ASSEMBLER__ is gcc predefined.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
