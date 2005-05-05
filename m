Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j45HrX61021164
	for <linux-mm@kvack.org>; Thu, 5 May 2005 13:53:33 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j45HrX8Y052080
	for <linux-mm@kvack.org>; Thu, 5 May 2005 13:53:33 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j45HrWd6019215
	for <linux-mm@kvack.org>; Thu, 5 May 2005 13:53:32 -0400
Date: Thu, 5 May 2005 10:53:20 -0700
From: mike kravetz <kravetz@us.ibm.com>
Subject: Re: [3/3] sparsemem memory model for ppc64
Message-ID: <20050505175320.GC3930@w-mikek2.ibm.com>
References: <E1DTQWH-0002We-I9@pinky.shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1DTQWH-0002We-I9@pinky.shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linuxppc64-dev@ozlabs.org, paulus@samba.org, anton@samba.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 04, 2005 at 09:30:57PM +0100, Andy Whitcroft wrote:
> +	/*
> +	 * Note presence of first (logical/coalasced) LMB which will
> +	 * contain RMO region
> +	 */
> +	start_pfn = lmb.memory.region[0].physbase >> PAGE_SHIFT;
> +	end_pfn = start_pfn + (lmb.memory.region[0].size >> PAGE_SHIFT);
> +	memory_present(0, start_pfn, end_pfn);

I need to take a close look at this again, but I think this special
handling for the RMO region in unnecessary.  I added it in the 'early
days of SPARSE' when there were some 'bootstrap' issues and we needed
to initialize some memory before setting up the bootmem bitmap.  I'm
pretty sure all those issues have gone away.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
