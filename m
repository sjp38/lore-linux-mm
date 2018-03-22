Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id F1D686B0033
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:02:10 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 129-v6so4723475oid.12
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:02:10 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v12-v6si2027136oth.407.2018.03.22.09.02.09
        for <linux-mm@kvack.org>;
        Thu, 22 Mar 2018 09:02:09 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [RFC, PATCH 08/22] mm: Introduce __GFP_ENCRYPT
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
	<20180305162610.37510-9-kirill.shutemov@linux.intel.com>
Date: Thu, 22 Mar 2018 16:02:06 +0000
In-Reply-To: <20180305162610.37510-9-kirill.shutemov@linux.intel.com> (Kirill
	A. Shutemov's message of "Mon, 5 Mar 2018 19:25:56 +0300")
Message-ID: <87sh8s14ld.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> The patch adds new gfp flag to indicate that we're allocating encrypted
> page.
>
> Architectural code may need to do special preparation for encrypted
> pages such as flushing cache to avoid aliasing.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/gfp.h            | 12 ++++++++++++
>  include/linux/mm.h             |  2 ++
>  include/trace/events/mmflags.h |  1 +
>  mm/Kconfig                     |  3 +++
>  mm/page_alloc.c                |  3 +++
>  tools/perf/builtin-kmem.c      |  1 +
>  6 files changed, 22 insertions(+)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 1a4582b44d32..43a93ca11c3c 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -24,6 +24,11 @@ struct vm_area_struct;
>  #define ___GFP_HIGH		0x20u
>  #define ___GFP_IO		0x40u
>  #define ___GFP_FS		0x80u
> +#ifdef CONFIG_ARCH_WANTS_GFP_ENCRYPT
> +#define ___GFP_ENCYPT		0x100u
> +#else
> +#define ___GFP_ENCYPT		0

s/___GFP_ENCYPT/___GFP_ENCRYPT?

Thanks,
Punit

[...]
