Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id E77746B0007
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 19:20:04 -0500 (EST)
Date: Fri, 1 Feb 2013 16:20:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/9] mm: add SECTION_IN_PAGE_FLAGS
Message-Id: <20130201162002.49eadeb7.akpm@linux-foundation.org>
In-Reply-To: <1358463181-17956-2-git-send-email-cody@linux.vnet.ibm.com>
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
	<1358463181-17956-2-git-send-email-cody@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>

On Thu, 17 Jan 2013 14:52:53 -0800
Cody P Schafer <cody@linux.vnet.ibm.com> wrote:

> Instead of directly utilizing a combination of config options to determine this,
> add a macro to specifically address it.
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -625,6 +625,10 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>  #define NODE_NOT_IN_PAGE_FLAGS
>  #endif
>  
> +#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
> +#define SECTION_IN_PAGE_FLAGS
> +#endif

We could do this in Kconfig itself, in the definition of a new
CONFIG_SECTION_IN_PAGE_FLAGS.

I'm not sure that I like that sort of thing a lot though - it's rather a
pain to have to switch from .[ch] over to Kconfig to find the
definitions of things.  I should get off my tail and teach my ctags
scripts to handle this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
