Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35E126B03F8
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 03:18:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c143so12500482wmd.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 00:18:15 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id a128si9771620wmc.82.2017.03.13.00.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 00:18:13 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id u48so18923708wrc.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 00:18:13 -0700 (PDT)
Date: Mon, 13 Mar 2017 08:18:10 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 21/26] x86/mm: add support of additional page table level
 during early boot
Message-ID: <20170313071810.GA28726@gmail.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
 <20170313055020.69655-22-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313055020.69655-22-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This patch adds support for 5-level paging during early boot.
> It generalizes boot for 4- and 5-level paging on 64-bit systems with
> compile-time switch between them.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S          | 23 +++++++++--
>  arch/x86/include/asm/pgtable.h              |  2 +-
>  arch/x86/include/asm/pgtable_64.h           |  6 ++-
>  arch/x86/include/uapi/asm/processor-flags.h |  2 +
>  arch/x86/kernel/espfix_64.c                 |  2 +-
>  arch/x86/kernel/head64.c                    | 40 +++++++++++++-----
>  arch/x86/kernel/head_64.S                   | 63 +++++++++++++++++++++--------

Ok, here I'd like to have a C version instead of further complicating an already 
complex assembly version...

I.e. the existing setup code should be converted to C in one patch, and then 
another patch should add 5-level paging support to the C code.

See how this was done for the 32-bit setup code already:

  5a7670ee23f2 x86/boot/32: Convert the 32-bit pgtable setup code from assembly to C

Also, please split it up into per boot path and topic, i.e. have a sparate patch 
for the Xen bits, the KASAN bits, the kexec extension, etc.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
