Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB976B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 04:42:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f6so7575885pfe.16
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:42:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m17si8909700pgn.776.2017.11.27.01.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 01:42:06 -0800 (PST)
Date: Mon, 27 Nov 2017 10:41:56 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch V2 4/5] x86/mm/debug_pagetables: Allow dumping current
 pagetables
Message-ID: <20171127094156.rbq7i7it7ojsblfj@hirez.programming.kicks-ass.net>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.563046145@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171126232414.563046145@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 12:14:07AM +0100, Thomas Gleixner wrote:
>  static int __init pt_dump_debug_init(void)
>  {
> +	pe_knl = debugfs_create_file("kernel_page_tables", S_IRUSR, NULL, NULL,
> +				     &ptdump_fops);
> +	if (!pe_knl)
>  		return -ENOMEM;
>  
> +	pe_curknl = debugfs_create_file("current_page_tables_knl", S_IRUSR,
> +					NULL, NULL, &ptdump_curknl_fops);
> +	if (!pe_curknl)
> +		goto err;
> +
> +#ifdef CONFIG_KAISER
> +	pe_curusr = debugfs_create_file("current_page_tables_usr", S_IRUSR,
> +					NULL, NULL, &ptdump_curusr_fops);
> +	if (!pe_curusr)
> +		goto err;
> +#endif
>  	return 0;
> +err:
> +	pt_dump_debug_remove_files();
> +	return -ENOMEM;
>  }


Could we pretty please use the octal permission thing? I can't read
thise S_crap nonsense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
