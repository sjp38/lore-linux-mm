Date: Fri, 15 Aug 2008 10:03:31 +0200
Subject: Re: sparsemem support for mips with highmem
Message-ID: <20080815080331.GA6689@alpha.franken.de>
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz> <48A4C542.5000308@sciatl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48A4C542.5000308@sciatl.com>
From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 14, 2008 at 04:52:34PM -0700, C Michael Sundius wrote:
> +
> +#ifndef CONFIG_64BIT
> +#define SECTION_SIZE_BITS       27	/* 128 MiB */
> +#define MAX_PHYSMEM_BITS        31	/* 2 GiB   */
> +#else
>  #define SECTION_SIZE_BITS       28
>  #define MAX_PHYSMEM_BITS        35
> +#endif

why is this needed ?

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
