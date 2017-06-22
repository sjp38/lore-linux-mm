Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91AE56B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:24:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z1so2897717wrz.10
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:24:58 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id 194si722146wmq.166.2017.06.22.02.24.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 02:24:57 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id x23so3135200wrb.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:24:57 -0700 (PDT)
Date: Thu, 22 Jun 2017 11:24:54 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 13/14] x86: Enable 5-level paging support
Message-ID: <20170622092454.n4f2uho5lsp6ox4q@gmail.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
 <20170606113133.22974-14-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170606113133.22974-14-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> Most of things are in place and we can enable support of 5-level paging.
> 
> The patch makes XEN_PV dependent on !X86_5LEVEL. XEN_PV is not ready to
> work with 5-level paging.

Please make a short comment about that in the Kconfig code as well, instead of a 
silent, undocumented 'depends' clause.

>  config PGTABLE_LEVELS
>  	int
> +	default 5 if X86_5LEVEL
>  	default 4 if X86_64
>  	default 3 if X86_PAE
>  	default 2
> @@ -1390,6 +1391,10 @@ config X86_PAE
>  	  has the cost of more pagetable lookup overhead, and also
>  	  consumes more pagetable space per process.
>  
> +config X86_5LEVEL
> +	bool "Enable 5-level page tables support"
> +	depends on X86_64

So since users will be enabling it, this needs a proper help text that explains 
what hardware supports it ("future Intel CPUs" will do if models are not public 
yet), a short blurb about what it's good for - and a link to the Documentation/ 
file explaining it all.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
