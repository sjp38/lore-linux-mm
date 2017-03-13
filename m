Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8921D6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 03:49:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g10so43193819wrg.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 00:49:17 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id k98si23513181wrc.76.2017.03.13.00.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 00:49:16 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id n11so8372342wma.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 00:49:15 -0700 (PDT)
Date: Mon, 13 Mar 2017 08:49:12 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/26] x86: 5-level paging enabling for v4.12
Message-ID: <20170313074912.GA4651@gmail.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> Kirill A. Shutemov (26):
>   x86: basic changes into headers for 5-level paging
>   x86: trivial portion of 5-level paging conversion
>   x86/gup: add 5-level paging support
>   x86/ident_map: add 5-level paging support
>   x86/mm: add support of p4d_t in vmalloc_fault()
>   x86/power: support p4d_t in hibernate code
>   x86/kexec: support p4d_t
>   x86/efi: handle p4d in EFI pagetables
>   x86/mm/pat: handle additional page table
>   x86/kasan: prepare clear_pgds() to switch to
>     <asm-generic/pgtable-nop4d.h>
>   x86/xen: convert __xen_pgd_walk() and xen_cleanmfnmap() to support p4d
>   x86: convert the rest of the code to support p4d_t
>   x86: detect 5-level paging support
>   x86/asm: remove __VIRTUAL_MASK_SHIFT==47 assert
>   x86/mm: define virtual memory map for 5-level paging
>   x86/paravirt: make paravirt code support 5-level paging
>   x86/mm: basic defines/helpers for CONFIG_X86_5LEVEL
>   x86/dump_pagetables: support 5-level paging
>   x86/kasan: extend to support 5-level paging
>   x86/espfix: support 5-level paging
>   x86/mm: add support of additional page table level during early boot
>   x86/mm: add sync_global_pgds() for configuration with 5-level paging
>   x86/mm: make kernel_physical_mapping_init() support 5-level paging
>   x86/mm: add support for 5-level paging for KASLR
>   x86: enable 5-level paging support
>   x86/mm: allow to have userspace mappings above 47-bits

Since we are cleaning up the series anyway, please fix the patch titles as well:

 - Please try to find the proper subsystem marker instead of a generic 'x86: ' 
   prefix. For example:

      x86: basic changes into headers for 5-level paging

   ... can be prefixed with "x86/headers: ..." or "x86/mm: ..."

 - Please always start the titles with verbs, to make it easy to parse 
   shortlogs and git oneliner logs quickly. I.e. instead of:

      x86: basic changes into headers for 5-level paging

   Use something like:

      x86/mm: Apply basic changes into headers for 5-level paging

 - Please capitalize them consistently, i.e. "x86/subsystem: Verb ...", with the 
   verb in upper case.

 - Also, please _read_ the titles and the changelogs, for example "basic changes 
   into headers" is not a valid, easy to parse English sentence...

I.e. applying all these 4 principles to the first line turns it from:

      x86: basic changes into headers for 5-level paging

... into something much more informative and easier to read:

      x86/mm: Extend headers with basic definitions to support 5-level paging

Please do this for all the other patches as well - almost all of them have one 
deficiency or some other, several have multiple such deficiencnies.

Ok?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
