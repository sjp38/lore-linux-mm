From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 06/17] arch: Set IORESOURCE_SYSTEM_RAM to System RAM
Date: Sun, 24 Jan 2016 19:00:57 +0100
Message-ID: <20160124180057.GC26879@pd.tnic>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
 <1452020081-26534-6-git-send-email-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1452020081-26534-6-git-send-email-toshi.kani@hpe.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org
List-Id: linux-mm.kvack.org

Adding the respective arch MLs to CC, as an FYI.

On Tue, Jan 05, 2016 at 11:54:30AM -0700, Toshi Kani wrote:
> Set IORESOURCE_SYSTEM_RAM to 'flags' of resource ranges with
> "System RAM", "Kernel code", "Kernel data", and "Kernel bss".
> 
> Note that:
>  - IORESOURCE_SYSRAM (i.e. modifier bit) is set to 'flags'
>    when IORESOURCE_MEM is already set.  IORESOURCE_SYSTEM_RAM
>    is defined as (IORESOURCE_MEM|IORESOURCE_SYSRAM).
>  - Some archs do not set 'flags' for children nodes, such as
>    "Kernel code".  This patch does not change 'flags' in this
>    case.
> 
> Cc: linux-arch@vger.kernel.org
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> ---
>  arch/arm/kernel/setup.c       |    6 +++---
>  arch/arm64/kernel/setup.c     |    6 +++---
>  arch/avr32/kernel/setup.c     |    6 +++---
>  arch/m32r/kernel/setup.c      |    4 ++--
>  arch/mips/kernel/setup.c      |   10 ++++++----
>  arch/parisc/mm/init.c         |    6 +++---
>  arch/powerpc/mm/mem.c         |    2 +-
>  arch/s390/kernel/setup.c      |    8 ++++----
>  arch/score/kernel/setup.c     |    2 +-
>  arch/sh/kernel/setup.c        |    8 ++++----
>  arch/sparc/mm/init_64.c       |    8 ++++----
>  arch/tile/kernel/setup.c      |   11 ++++++++---
>  arch/unicore32/kernel/setup.c |    6 +++---
>  13 files changed, 45 insertions(+), 38 deletions(-)
> 
> diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
> index 20edd34..ae44e09 100644
> --- a/arch/arm/kernel/setup.c
> +++ b/arch/arm/kernel/setup.c
> @@ -173,13 +173,13 @@ static struct resource mem_res[] = {
>  		.name = "Kernel code",
>  		.start = 0,
>  		.end = 0,
> -		.flags = IORESOURCE_MEM
> +		.flags = IORESOURCE_SYSTEM_RAM
>  	},
>  	{
>  		.name = "Kernel data",
>  		.start = 0,
>  		.end = 0,
> -		.flags = IORESOURCE_MEM
> +		.flags = IORESOURCE_SYSTEM_RAM
>  	}
>  };
>  
> @@ -781,7 +781,7 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
>  		res->name  = "System RAM";
>  		res->start = __pfn_to_phys(memblock_region_memory_base_pfn(region));
>  		res->end = __pfn_to_phys(memblock_region_memory_end_pfn(region)) - 1;
> -		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>  
>  		request_resource(&iomem_resource, res);
>  
> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index 8119479..450987d 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -73,13 +73,13 @@ static struct resource mem_res[] = {
>  		.name = "Kernel code",
>  		.start = 0,
>  		.end = 0,
> -		.flags = IORESOURCE_MEM
> +		.flags = IORESOURCE_SYSTEM_RAM
>  	},
>  	{
>  		.name = "Kernel data",
>  		.start = 0,
>  		.end = 0,
> -		.flags = IORESOURCE_MEM
> +		.flags = IORESOURCE_SYSTEM_RAM
>  	}
>  };
>  
> @@ -210,7 +210,7 @@ static void __init request_standard_resources(void)
>  		res->name  = "System RAM";
>  		res->start = __pfn_to_phys(memblock_region_memory_base_pfn(region));
>  		res->end = __pfn_to_phys(memblock_region_memory_end_pfn(region)) - 1;
> -		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>  
>  		request_resource(&iomem_resource, res);
>  
> diff --git a/arch/avr32/kernel/setup.c b/arch/avr32/kernel/setup.c
> index 209ae5a..e692889 100644
> --- a/arch/avr32/kernel/setup.c
> +++ b/arch/avr32/kernel/setup.c
> @@ -49,13 +49,13 @@ static struct resource __initdata kernel_data = {
>  	.name	= "Kernel data",
>  	.start	= 0,
>  	.end	= 0,
> -	.flags	= IORESOURCE_MEM,
> +	.flags	= IORESOURCE_SYSTEM_RAM,
>  };
>  static struct resource __initdata kernel_code = {
>  	.name	= "Kernel code",
>  	.start	= 0,
>  	.end	= 0,
> -	.flags	= IORESOURCE_MEM,
> +	.flags	= IORESOURCE_SYSTEM_RAM,
>  	.sibling = &kernel_data,
>  };
>  
> @@ -134,7 +134,7 @@ add_physical_memory(resource_size_t start, resource_size_t end)
>  	new->start = start;
>  	new->end = end;
>  	new->name = "System RAM";
> -	new->flags = IORESOURCE_MEM;
> +	new->flags = IORESOURCE_SYSTEM_RAM;
>  
>  	*pprev = new;
>  }
> diff --git a/arch/m32r/kernel/setup.c b/arch/m32r/kernel/setup.c
> index 0392112..5f62ff0 100644
> --- a/arch/m32r/kernel/setup.c
> +++ b/arch/m32r/kernel/setup.c
> @@ -70,14 +70,14 @@ static struct resource data_resource = {
>  	.name   = "Kernel data",
>  	.start  = 0,
>  	.end    = 0,
> -	.flags  = IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags  = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
>  };
>  
>  static struct resource code_resource = {
>  	.name   = "Kernel code",
>  	.start  = 0,
>  	.end    = 0,
> -	.flags  = IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags  = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
>  };
>  
>  unsigned long memory_start;
> diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
> index 66aac55..c385af1 100644
> --- a/arch/mips/kernel/setup.c
> +++ b/arch/mips/kernel/setup.c
> @@ -732,21 +732,23 @@ static void __init resource_init(void)
>  			end = HIGHMEM_START - 1;
>  
>  		res = alloc_bootmem(sizeof(struct resource));
> +
> +		res->start = start;
> +		res->end = end;
> +		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +
>  		switch (boot_mem_map.map[i].type) {
>  		case BOOT_MEM_RAM:
>  		case BOOT_MEM_INIT_RAM:
>  		case BOOT_MEM_ROM_DATA:
>  			res->name = "System RAM";
> +			res->flags |= IORESOURCE_SYSRAM;
>  			break;
>  		case BOOT_MEM_RESERVED:
>  		default:
>  			res->name = "reserved";
>  		}
>  
> -		res->start = start;
> -		res->end = end;
> -
> -		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>  		request_resource(&iomem_resource, res);
>  
>  		/*
> diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
> index 1b366c4..3c07d6b 100644
> --- a/arch/parisc/mm/init.c
> +++ b/arch/parisc/mm/init.c
> @@ -55,12 +55,12 @@ signed char pfnnid_map[PFNNID_MAP_MAX] __read_mostly;
>  
>  static struct resource data_resource = {
>  	.name	= "Kernel data",
> -	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM,
> +	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
>  };
>  
>  static struct resource code_resource = {
>  	.name	= "Kernel code",
> -	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM,
> +	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
>  };
>  
>  static struct resource pdcdata_resource = {
> @@ -201,7 +201,7 @@ static void __init setup_bootmem(void)
>  		res->name = "System RAM";
>  		res->start = pmem_ranges[i].start_pfn << PAGE_SHIFT;
>  		res->end = res->start + (pmem_ranges[i].pages << PAGE_SHIFT)-1;
> -		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>  		request_resource(&iomem_resource, res);
>  	}
>  
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 22d94c3..e78a2b7 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -541,7 +541,7 @@ static int __init add_system_ram_resources(void)
>  			res->name = "System RAM";
>  			res->start = base;
>  			res->end = base + size - 1;
> -			res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +			res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>  			WARN_ON(request_resource(&iomem_resource, res) < 0);
>  		}
>  	}
> diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
> index c837bca..b65a883 100644
> --- a/arch/s390/kernel/setup.c
> +++ b/arch/s390/kernel/setup.c
> @@ -376,17 +376,17 @@ static void __init setup_lowcore(void)
>  
>  static struct resource code_resource = {
>  	.name  = "Kernel code",
> -	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
> +	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
>  };
>  
>  static struct resource data_resource = {
>  	.name = "Kernel data",
> -	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
> +	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
>  };
>  
>  static struct resource bss_resource = {
>  	.name = "Kernel bss",
> -	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
> +	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
>  };
>  
>  static struct resource __initdata *standard_resources[] = {
> @@ -410,7 +410,7 @@ static void __init setup_resources(void)
>  
>  	for_each_memblock(memory, reg) {
>  		res = alloc_bootmem_low(sizeof(*res));
> -		res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
> +		res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
>  
>  		res->name = "System RAM";
>  		res->start = reg->base;
> diff --git a/arch/score/kernel/setup.c b/arch/score/kernel/setup.c
> index b48459a..f3a0649 100644
> --- a/arch/score/kernel/setup.c
> +++ b/arch/score/kernel/setup.c
> @@ -101,7 +101,7 @@ static void __init resource_init(void)
>  	res->name = "System RAM";
>  	res->start = MEMORY_START;
>  	res->end = MEMORY_START + MEMORY_SIZE - 1;
> -	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>  	request_resource(&iomem_resource, res);
>  
>  	request_resource(res, &code_resource);
> diff --git a/arch/sh/kernel/setup.c b/arch/sh/kernel/setup.c
> index de19cfa..3f1c18b 100644
> --- a/arch/sh/kernel/setup.c
> +++ b/arch/sh/kernel/setup.c
> @@ -78,17 +78,17 @@ static char __initdata command_line[COMMAND_LINE_SIZE] = { 0, };
>  
>  static struct resource code_resource = {
>  	.name = "Kernel code",
> -	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
> +	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
>  };
>  
>  static struct resource data_resource = {
>  	.name = "Kernel data",
> -	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
> +	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
>  };
>  
>  static struct resource bss_resource = {
>  	.name	= "Kernel bss",
> -	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM,
> +	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
>  };
>  
>  unsigned long memory_start;
> @@ -202,7 +202,7 @@ void __init __add_active_range(unsigned int nid, unsigned long start_pfn,
>  	res->name = "System RAM";
>  	res->start = start;
>  	res->end = end - 1;
> -	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>  
>  	if (request_resource(&iomem_resource, res)) {
>  		pr_err("unable to request memory_resource 0x%lx 0x%lx\n",
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index 3025bd5..a02d43d 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -2862,17 +2862,17 @@ void hugetlb_setup(struct pt_regs *regs)
>  
>  static struct resource code_resource = {
>  	.name	= "Kernel code",
> -	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
>  };
>  
>  static struct resource data_resource = {
>  	.name	= "Kernel data",
> -	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
>  };
>  
>  static struct resource bss_resource = {
>  	.name	= "Kernel bss",
> -	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
>  };
>  
>  static inline resource_size_t compute_kern_paddr(void *addr)
> @@ -2908,7 +2908,7 @@ static int __init report_memory(void)
>  		res->name = "System RAM";
>  		res->start = pavail[i].phys_addr;
>  		res->end = pavail[i].phys_addr + pavail[i].reg_size - 1;
> -		res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
> +		res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
>  
>  		if (insert_resource(&iomem_resource, res) < 0) {
>  			pr_warn("Resource insertion failed.\n");
> diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
> index 6b755d1..6606fe2 100644
> --- a/arch/tile/kernel/setup.c
> +++ b/arch/tile/kernel/setup.c
> @@ -1632,14 +1632,14 @@ static struct resource data_resource = {
>  	.name	= "Kernel data",
>  	.start	= 0,
>  	.end	= 0,
> -	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
>  };
>  
>  static struct resource code_resource = {
>  	.name	= "Kernel code",
>  	.start	= 0,
>  	.end	= 0,
> -	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
>  };
>  
>  /*
> @@ -1673,10 +1673,15 @@ insert_ram_resource(u64 start_pfn, u64 end_pfn, bool reserved)
>  		kzalloc(sizeof(struct resource), GFP_ATOMIC);
>  	if (!res)
>  		return NULL;
> -	res->name = reserved ? "Reserved" : "System RAM";
>  	res->start = start_pfn << PAGE_SHIFT;
>  	res->end = (end_pfn << PAGE_SHIFT) - 1;
>  	res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
> +	if (reserved) {
> +		res->name = "Reserved";
> +	} else {
> +		res->name = "System RAM";
> +		res->flags |= IORESOURCE_SYSRAM;
> +	}
>  	if (insert_resource(&iomem_resource, res)) {
>  		kfree(res);
>  		return NULL;
> diff --git a/arch/unicore32/kernel/setup.c b/arch/unicore32/kernel/setup.c
> index 3fa317f..c2bffa5 100644
> --- a/arch/unicore32/kernel/setup.c
> +++ b/arch/unicore32/kernel/setup.c
> @@ -72,13 +72,13 @@ static struct resource mem_res[] = {
>  		.name = "Kernel code",
>  		.start = 0,
>  		.end = 0,
> -		.flags = IORESOURCE_MEM
> +		.flags = IORESOURCE_SYSTEM_RAM
>  	},
>  	{
>  		.name = "Kernel data",
>  		.start = 0,
>  		.end = 0,
> -		.flags = IORESOURCE_MEM
> +		.flags = IORESOURCE_SYSTEM_RAM
>  	}
>  };
>  
> @@ -211,7 +211,7 @@ request_standard_resources(struct meminfo *mi)
>  		res->name  = "System RAM";
>  		res->start = mi->bank[i].start;
>  		res->end   = mi->bank[i].start + mi->bank[i].size - 1;
> -		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>  
>  		request_resource(&iomem_resource, res);
>  
> 

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
