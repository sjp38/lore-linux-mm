Date: Wed, 30 Aug 2006 16:57:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 4/9] ia64 generic PAGE_SIZE
In-Reply-To: <20060830221607.1DB81421@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0608301652270.5789@schroedinger.engr.sgi.com>
References: <20060830221604.E7320C0F@localhost.localdomain>
 <20060830221607.1DB81421@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Aug 2006, Dave Hansen wrote:

> @@ -64,11 +64,11 @@
>   * Base-2 logarithm of number of pages to allocate per task structure
>   * (including register backing store and memory stack):
>   */
> -#if defined(CONFIG_IA64_PAGE_SIZE_4KB)
> +#if defined(CONFIG_PAGE_SIZE_4KB)
>  # define KERNEL_STACK_SIZE_ORDER		3
> -#elif defined(CONFIG_IA64_PAGE_SIZE_8KB)
> +#elif defined(CONFIG_PAGE_SIZE_8KB)
>  # define KERNEL_STACK_SIZE_ORDER		2
> -#elif defined(CONFIG_IA64_PAGE_SIZE_16KB)
> +#elif defined(CONFIG_PAGE_SIZE_16KB)
>  # define KERNEL_STACK_SIZE_ORDER		1
>  #else
>  # define KERNEL_STACK_SIZE_ORDER		0

Could we replace these lines with

#define KERNEL_STACK_SIZE_ORDER (max(0, 15 - PAGE_SHIFT)) 

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
