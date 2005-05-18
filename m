Date: 18 May 2005 18:27:10 +0200
Date: Wed, 18 May 2005 18:27:10 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: [patch 4/4] add x86-64 specific support for sparsemem
Message-ID: <20050518162710.GD88141@muc.de>
References: <200505181528.j4IFSTo1026925@snoqualmie.dp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200505181528.j4IFSTo1026925@snoqualmie.dp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Cc: akpm@osdl.org, apw@shadowen.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -400,9 +401,12 @@ static __init void parse_cmdline_early (
>  }
>  
>  #ifndef CONFIG_NUMA
> -static void __init contig_initmem_init(void)
> +static void __init
> +contig_initmem_init(unsigned long start_pfn, unsigned long end_pfn)
>  {
>          unsigned long bootmap_size, bootmap; 
> +
> +	memory_present(0, start_pfn, end_pfn);

Watch indentation.

Rest looks good.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
