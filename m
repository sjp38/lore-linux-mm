Date: Thu, 27 Mar 2008 20:23:34 -0700 (PDT)
Message-Id: <20080327.202334.250213398.davem@davemloft.net>
Subject: Re: [patch 1/2]: x86: implement pte_special
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080328025541.GB8083@wotan.suse.de>
References: <20080328025455.GA8083@wotan.suse.de>
	<20080328025541.GB8083@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Fri, 28 Mar 2008 03:55:41 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, shaggy@austin.ibm.com, axboe@oracle.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> @@ -40,6 +41,8 @@
>  #define _PAGE_UNUSED3	(_AC(1, L)<<_PAGE_BIT_UNUSED3)
>  #define _PAGE_PAT	(_AC(1, L)<<_PAGE_BIT_PAT)
>  #define _PAGE_PAT_LARGE (_AC(1, L)<<_PAGE_BIT_PAT_LARGE)
> +#define _PAGE_SPECIAL	(_AC(1, L)<<_PAGE_BIT_SPECIAL)
> +#define __HAVE_ARCH_PTE_SPECIAL

What tests __HAVE_ARCH_PTE_SPECIAL?

> @@ -167,7 +170,7 @@ static inline pte_t pte_mkhuge(pte_t pte
>  static inline pte_t pte_clrhuge(pte_t pte)	{ return __pte(pte_val(pte) & ~(pteval_t)_PAGE_PSE); }
>  static inline pte_t pte_mkglobal(pte_t pte)	{ return __pte(pte_val(pte) | _PAGE_GLOBAL); }
>  static inline pte_t pte_clrglobal(pte_t pte)	{ return __pte(pte_val(pte) & ~(pteval_t)_PAGE_GLOBAL); }
> -static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
> +static inline pte_t pte_mkspecial(pte_t pte)	{ return __pte(pte_val(pte) | _PAGE_SPECIAL); }

And what calls pte_mkspecial?

I don't see any code that sets the special bit anywhere
in these two patches.

What am I missing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
