From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 1/2] mm: implement remap_pfn_range with apply_to_page_range
Date: Fri, 14 Nov 2008 14:17:35 +1100
References: <491C61B1.10005@goop.org> <200811141319.56713.nickpiggin@yahoo.com.au> <491CE8C6.4060000@goop.org>
In-Reply-To: <491CE8C6.4060000@goop.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200811141417.35724.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

On Friday 14 November 2008 13:56, Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> > This isn't performance critical to anyone?
>
> The only difference should be between having the specialized code and an
> indirect function call, no?

Indirect function call per pte. It's going to be slower surely.


> > I see DRM, IB, GRU, other media and video drivers use it.
> >
> > It IS exactly what apply_to_page_range does, I grant you. But so does
> > our traditional set of nested loops. So is there any particular reason
> > to change it? You're not planning to change fork/exit next, are you? :)
>
> No ;)  But I need to have a more Xen-specific version of
> remap_pfn_range, and I wanted to 1) have the two versions look as
> similar as possible, and 2) not have a pile of duplicate code.

It is accepted practice to (carefully) duplicate the page table walking
functions in memory management code. I don't think that's a problem,
there is already so many instances of them (just be sure to stick to
exactly the same form and variable names, and any update or bugfix to
any of them is trivially applicable to all).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
