Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7FIO3Ua024528
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 14:24:03 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7FIO00s177736
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 12:24:03 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7FIO0OT030141
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 12:24:00 -0600
Subject: Re: sparsemem support for mips with highmem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48A5C831.3070002@sciatl.com>
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz>
	 <48A4C542.5000308@sciatl.com> <20080815080331.GA6689@alpha.franken.de>
	 <1218815299.23641.80.camel@nimitz> <48A5AADE.1050808@sciatl.com>
	 <20080815163302.GA9846@alpha.franken.de>  <48A5B9F1.3080201@sciatl.com>
	 <1218821875.23641.103.camel@nimitz>  <48A5C831.3070002@sciatl.com>
Content-Type: text/plain
Date: Fri, 15 Aug 2008 11:23:58 -0700
Message-Id: <1218824638.23641.106.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-08-15 at 11:17 -0700, C Michael Sundius wrote:
> 
> diff --git a/include/asm-mips/sparsemem.h
> b/include/asm-mips/sparsemem.h
> index 795ac6c..64376db 100644
> --- a/include/asm-mips/sparsemem.h
> +++ b/include/asm-mips/sparsemem.h
> @@ -6,7 +6,7 @@
>   * SECTION_SIZE_BITS           2^N: how big each section will be
>   * MAX_PHYSMEM_BITS            2^N: how much memory we can have in
> that space
>   */
> -#define SECTION_SIZE_BITS       28
> +#define SECTION_SIZE_BITS       27     /* 128 MiB */
>  #define MAX_PHYSMEM_BITS        35

This looks great to me, as long as the existing MIPS users like it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
