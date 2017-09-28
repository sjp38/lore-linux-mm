Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE5D6B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:28:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i133so247224wme.11
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:28:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9sor355066wrg.50.2017.09.28.01.28.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:28:16 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:28:13 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 10/19] x86/mm: Make __PHYSICAL_MASK_SHIFT and
 __VIRTUAL_MASK_SHIFT dynamic
Message-ID: <20170928082813.lvr45p53niznhycx@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-11-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-11-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> --- a/arch/x86/mm/dump_pagetables.c
> +++ b/arch/x86/mm/dump_pagetables.c
> @@ -82,8 +82,8 @@ static struct addr_marker address_markers[] = {
>  	{ 0/* VMALLOC_START */, "vmalloc() Area" },
>  	{ 0/* VMEMMAP_START */, "Vmemmap" },
>  #ifdef CONFIG_KASAN
> -	{ KASAN_SHADOW_START,	"KASAN shadow" },
> -	{ KASAN_SHADOW_END,	"KASAN shadow end" },
> +	{ 0/* KASAN_SHADOW_START */,	"KASAN shadow" },
> +	{ 0/* KASAN_SHADOW_END */,	"KASAN shadow end" },

What's this? Looks hacky.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
