Message-ID: <491CE8C6.4060000@goop.org>
Date: Thu, 13 Nov 2008 18:56:06 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: implement remap_pfn_range with apply_to_page_range
References: <491C61B1.10005@goop.org> <200811141319.56713.nickpiggin@yahoo.com.au>
In-Reply-To: <200811141319.56713.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
>
> This isn't performance critical to anyone?
>   

The only difference should be between having the specialized code and an 
indirect function call, no?

> I see DRM, IB, GRU, other media and video drivers use it.
>
> It IS exactly what apply_to_page_range does, I grant you. But so does
> our traditional set of nested loops. So is there any particular reason
> to change it? You're not planning to change fork/exit next, are you? :)
>   

No ;)  But I need to have a more Xen-specific version of 
remap_pfn_range, and I wanted to 1) have the two versions look as 
similar as possible, and 2) not have a pile of duplicate code.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
