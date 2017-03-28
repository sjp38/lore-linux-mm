Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86BD56B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:11:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id e11so3370336wra.0
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 23:11:25 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id w75si2158691wmd.74.2017.03.27.23.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 23:11:24 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id 20so19306590wrx.0
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 23:11:24 -0700 (PDT)
Date: Tue, 28 Mar 2017 08:11:21 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 5/8] x86/mm: Add basic defines/helpers for
 CONFIG_X86_5LEVEL
Message-ID: <20170328061121.GB20135@gmail.com>
References: <20170327162925.16092-1-kirill.shutemov@linux.intel.com>
 <20170327162925.16092-6-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170327162925.16092-6-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> +#ifdef CONFIG_X86_5LEVEL
> +
> +/*
> + * PGDIR_SHIFT determines what a top-level page table entry can map
> + */
> +#define PGDIR_SHIFT	48
> +#define PTRS_PER_PGD	512
> +
> +/*
> + * 4rd level page in 5-level paging case

4th.

> + */
> +#define P4D_SHIFT	39
> +#define PTRS_PER_P4D	512
> +#define P4D_SIZE	(_AC(1, UL) << P4D_SHIFT)
> +#define P4D_MASK	(~(P4D_SIZE - 1))
> +
> +#else  /* CONFIG_X86_5LEVEL */

Single space suffices before teh comment.

> +
>  /*
>   * PGDIR_SHIFT determines what a top-level page table entry can map
>   */
>  #define PGDIR_SHIFT	39
>  #define PTRS_PER_PGD	512
>  
> +#endif  /* CONFIG_X86_5LEVEL */

Ditto.

> +#ifdef CONFIG_X86_5LEVEL
> +/**
> + * p4d_set_huge - setup kernel P4D mapping
> + *
> + * No 512GB pages yet -- always return 0
> + *
> + * Returns 1 on success and 0 on failure.
> + */
> +int p4d_set_huge(p4d_t *p4d, phys_addr_t addr, pgprot_t prot)
> +{
> +	return 0;
> +}

The last comment line can be deleted I suppose.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
