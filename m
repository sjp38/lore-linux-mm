Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF23A6B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:18:15 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q12so1388149pli.12
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:18:15 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d11si23928668plr.754.2017.11.27.10.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 10:18:14 -0800 (PST)
Subject: Re: [patch V2 4/5] x86/mm/debug_pagetables: Allow dumping current
 pagetables
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.563046145@linutronix.de>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <42b00525-e827-5556-46ac-a682a1282858@linux.intel.com>
Date: Mon, 27 Nov 2017 10:18:12 -0800
MIME-Version: 1.0
In-Reply-To: <20171126232414.563046145@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 11/26/2017 03:14 PM, Thomas Gleixner wrote:
> -void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd)
> +void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool shadow)
>  {
> +	if (shadow)
> +		pgd += PTRS_PER_PGD;
>  	ptdump_walk_pgd_level_core(m, pgd, false, false);
>  }

Same comment about calculating the shadow pgd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
