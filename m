Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 685606B03EB
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 03:22:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w37so44695709wrc.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 00:22:32 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id r205si9787823wma.48.2017.03.13.00.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 00:22:30 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n11so8284106wma.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 00:22:30 -0700 (PDT)
Date: Mon, 13 Mar 2017 08:22:27 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 22/26] x86/mm: add sync_global_pgds() for configuration
 with 5-level paging
Message-ID: <20170313072227.GB28726@gmail.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
 <20170313055020.69655-23-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313055020.69655-23-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This basically restores slightly modified version of original
> sync_global_pgds() which we had before foldedl p4d was introduced.

Please read your changelogs, I saw several typos/grammar mistakes in earlier 
patches. The one here is:

	s/foldedl/folded

> +	for (address = start; address <= end && address >= start;
> +			address += PGDIR_SIZE) {

Please don't address col80 checkpatch warnings by breaking the line in such an 
ugly way! Find another method, or just leave it slightly longer than 80 cols.

This one could probably be solved by:

	s/address/addr

... which is the canonical variable name for such iterations anyway.

> +			/* the pgt_lock only for Xen */

Please use whole sentences in comments, and please capitalize them properly.

I.e. here:


			/* We acquire the pgt_lock only for Xen: */

> +				BUG_ON(pgd_page_vaddr(*pgd)
> +						!= pgd_page_vaddr(*pgd_ref));

Ugly col80 artifact ...

Please review the rest of the series for similar patterns as well, and please only 
post 5-10 patches in the next submission - we'll review and apply them step by 
step.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
