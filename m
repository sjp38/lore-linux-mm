Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 4AF276B0037
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 20:55:45 -0400 (EDT)
Message-ID: <52213EBD.8060609@huawei.com>
Date: Sat, 31 Aug 2013 08:54:21 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/arch: use NUMA_NODE
References: <521FFE3B.7040801@huawei.com>
In-Reply-To: <521FFE3B.7040801@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

Cc linux-mm@kvack.org

On 2013/8/30 10:06, Jianguo Wu wrote:

> Use more appropriate NUMA_NO_NODE instead of -1 in some archs' module_alloc()
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> ---
>  arch/arm/kernel/module.c    |    2 +-
>  arch/arm64/kernel/module.c  |    2 +-
>  arch/mips/kernel/module.c   |    2 +-
>  arch/parisc/kernel/module.c |    2 +-
>  arch/s390/kernel/module.c   |    2 +-
>  arch/sparc/kernel/module.c  |    2 +-
>  arch/x86/kernel/module.c    |    2 +-
>  7 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/arm/kernel/module.c b/arch/arm/kernel/module.c
> index 85c3fb6..8f4cff3 100644
> --- a/arch/arm/kernel/module.c
> +++ b/arch/arm/kernel/module.c
> @@ -40,7 +40,7 @@
>  void *module_alloc(unsigned long size)
>  {
>  	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
> -				GFP_KERNEL, PAGE_KERNEL_EXEC, -1,
> +				GFP_KERNEL, PAGE_KERNEL_EXEC, NUMA_NO_NODE,
>  				__builtin_return_address(0));
>  }
>  #endif
> diff --git a/arch/arm64/kernel/module.c b/arch/arm64/kernel/module.c
> index ca0e3d5..8f898bd 100644
> --- a/arch/arm64/kernel/module.c
> +++ b/arch/arm64/kernel/module.c
> @@ -29,7 +29,7 @@
>  void *module_alloc(unsigned long size)
>  {
>  	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
> -				    GFP_KERNEL, PAGE_KERNEL_EXEC, -1,
> +				    GFP_KERNEL, PAGE_KERNEL_EXEC, NUMA_NO_NODE,
>  				    __builtin_return_address(0));
>  }
>  
> diff --git a/arch/mips/kernel/module.c b/arch/mips/kernel/module.c
> index 977a623..b507e07 100644
> --- a/arch/mips/kernel/module.c
> +++ b/arch/mips/kernel/module.c
> @@ -46,7 +46,7 @@ static DEFINE_SPINLOCK(dbe_lock);
>  void *module_alloc(unsigned long size)
>  {
>  	return __vmalloc_node_range(size, 1, MODULE_START, MODULE_END,
> -				GFP_KERNEL, PAGE_KERNEL, -1,
> +				GFP_KERNEL, PAGE_KERNEL, NUMA_NO_NODE,
>  				__builtin_return_address(0));
>  }
>  #endif
> diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
> index 2a625fb..50dfafc 100644
> --- a/arch/parisc/kernel/module.c
> +++ b/arch/parisc/kernel/module.c
> @@ -219,7 +219,7 @@ void *module_alloc(unsigned long size)
>  	 * init_data correctly */
>  	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
>  				    GFP_KERNEL | __GFP_HIGHMEM,
> -				    PAGE_KERNEL_RWX, -1,
> +				    PAGE_KERNEL_RWX, NUMA_NO_NODE,
>  				    __builtin_return_address(0));
>  }
>  
> diff --git a/arch/s390/kernel/module.c b/arch/s390/kernel/module.c
> index 7845e15..b89b591 100644
> --- a/arch/s390/kernel/module.c
> +++ b/arch/s390/kernel/module.c
> @@ -50,7 +50,7 @@ void *module_alloc(unsigned long size)
>  	if (PAGE_ALIGN(size) > MODULES_LEN)
>  		return NULL;
>  	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
> -				    GFP_KERNEL, PAGE_KERNEL, -1,
> +				    GFP_KERNEL, PAGE_KERNEL, NUMA_NO_NODE,
>  				    __builtin_return_address(0));
>  }
>  #endif
> diff --git a/arch/sparc/kernel/module.c b/arch/sparc/kernel/module.c
> index 4435488..97655e0 100644
> --- a/arch/sparc/kernel/module.c
> +++ b/arch/sparc/kernel/module.c
> @@ -29,7 +29,7 @@ static void *module_map(unsigned long size)
>  	if (PAGE_ALIGN(size) > MODULES_LEN)
>  		return NULL;
>  	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
> -				GFP_KERNEL, PAGE_KERNEL, -1,
> +				GFP_KERNEL, PAGE_KERNEL, NUMA_NO_NODE,
>  				__builtin_return_address(0));
>  }
>  #else
> diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
> index 216a4d7..18be189 100644
> --- a/arch/x86/kernel/module.c
> +++ b/arch/x86/kernel/module.c
> @@ -49,7 +49,7 @@ void *module_alloc(unsigned long size)
>  		return NULL;
>  	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
>  				GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC,
> -				-1, __builtin_return_address(0));
> +				NUMA_NO_NODE, __builtin_return_address(0));
>  }
>  
>  #ifdef CONFIG_X86_32



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
