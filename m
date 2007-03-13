Date: Tue, 13 Mar 2007 14:48:05 -0700 (PDT)
Message-Id: <20070313.144805.28789513.davem@davemloft.net>
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070313211435.GP10394@waste.org>
References: <20070313202125.GO10394@waste.org>
	<20070313.140722.72711732.davem@davemloft.net>
	<20070313211435.GP10394@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Matt Mackall <mpm@selenic.com>
Date: Tue, 13 Mar 2007 16:14:35 -0500
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: jeremy@goop.org, nickpiggin@yahoo.com.au, akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Well you -could- do this:
> 
> - reuse a long in struct page as a used map that divides the page up
>   into 32 or 64 segments
> - every time you set a PTE, set the corresponding bit in the mask
> - when we zap, only visit the regions set in the mask
> 
> Thus, you avoid visiting most of a PMD page in the sparse case,
> assuming PTEs aren't evenly spread across the PMD.
> 
> This might not even be too horrible as the appropriate struct page
> should be in cache with the appropriate bits of the mm already locked,
> etc.

Yes, I've even had that idea before.

You can even hide it behind pmd_none() et al., the generic VM
doesn't even have to know that the page table macros are doing
this optimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
