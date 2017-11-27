Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2795C6B0069
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:17:41 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q7so15072260pgr.10
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:17:41 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t25si22872228pgv.644.2017.11.27.10.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 10:17:40 -0800 (PST)
Subject: Re: [patch V2 3/5] x86/dump_pagetables: Check KAISER shadow page
 table for WX pages
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.481903103@linutronix.de>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <962b2ed0-89e7-5061-f33a-e8dcd6d9c6da@linux.intel.com>
Date: Mon, 27 Nov 2017 10:17:38 -0800
MIME-Version: 1.0
In-Reply-To: <20171126232414.481903103@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 11/26/2017 03:14 PM, Thomas Gleixner wrote:
> +void ptdump_walk_shadow_pgd_level_checkwx(void)
> +{
> +#ifdef CONFIG_KAISER
> +	pgd_t *pgd = (pgd_t *) &init_top_pgt;
> +
> +	pr_info("x86/mm: Checking shadow page tables\n");
> +	pgd += PTRS_PER_PGD;
> +	ptdump_walk_pgd_level_core(NULL, pgd, true, false);
> +#endif
>  }

We have the kernel_to_shadow_pgdp() function to use instead of "pgd +=
PTRS_PER_PGD;".  Should it be used instead?

Otherwise, looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
