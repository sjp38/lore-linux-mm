Message-ID: <45F7194B.5080705@goop.org>
Date: Tue, 13 Mar 2007 14:36:11 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
References: <20070313200313.GG10459@waste.org> <45F706BC.7060407@goop.org> <20070313202125.GO10394@waste.org> <20070313.140722.72711732.davem@davemloft.net> <20070313211435.GP10394@waste.org>
In-Reply-To: <20070313211435.GP10394@waste.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: David Miller <davem@davemloft.net>, nickpiggin@yahoo.com.au, akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Matt Mackall wrote:
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
>   

And do the same in pte pages for actual mapped pages?  Or do you think
they would be too densely populated for it to be worthwhile?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
