Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 149B26B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 11:48:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r133so7532642pgr.6
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 08:48:52 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 60si5597106plb.982.2017.08.07.08.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 08:48:50 -0700 (PDT)
Date: Mon, 7 Aug 2017 08:48:50 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCHv3 07/13] x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D
 variable
Message-ID: <20170807154850.GF3946@tassilo.jf.intel.com>
References: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
 <20170807141451.80934-8-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170807141451.80934-8-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> +#ifdef CONFIG_X86_5LEVEL
> +unsigned int pgdir_shift = 48;
> +unsigned int ptrs_per_p4d = 512;

should be both __read_mostly

> +#ifdef CONFIG_X86_5LEVEL
> +unsigned int pgdir_shift = 48;
> +EXPORT_SYMBOL(pgdir_shift);
> +unsigned int ptrs_per_p4d = 512;
> +EXPORT_SYMBOL(ptrs_per_p4d);
> +#endif

Same.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
