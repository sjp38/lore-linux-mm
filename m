Date: Mon, 6 Oct 2003 16:35:41 +0800
From: Eugene Teo <eugene.teo@eugeneteo.net>
Subject: Re: Code that does page outs
Message-ID: <20031006083541.GA6365@despammed.com>
Reply-To: Eugene Teo <eugeneteo@despammed.com>
References: <20031006063253.GA5231@despammed.com> <20031006000201.1804ba97.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031006000201.1804ba97.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Paul. Actually, I have identified, and read the code
starting from try_to_swap_out, then swap_out_pmd, then swap_out_pgd,
then swap_out_vma, then swap_out_mm, then swap_out, which returns
the number of pages swapped out. I have also read shrink_cache and
also took note of the number of pages swapped out. I am just wondering
if I have missed out any portion of the mm that can lead to page being
swap out. Anyhow, thank you for your tip for I have been using this
website too, along with my other materials.

<quote sender="Paul Jackson">
> > I am looking for possible areas in the kernel code where ...
> 
> May I recommend to you the site:
> 
>    Cross-Referencing Linux
>    http://lxr.linux.no
> 
> For example, start with an "identifier search" on one of the symbols you
> identified, try_to_swap_out:
> 
>    http://lxr.linux.no/ident?i=try_to_swap_out
> 
> This page will show where it is defined, and what calls it. Examine the
> code that defines try_to_swap_out().  Observe the critical between lines
> 133 and 148 of this file, vmscan.c. This is where it gets a free swap
> entry, get_swap_page(), and assigns the current page to that entry,
> add_to_swap_cache().
> 
> I would expect that any other piece of code that wants to swap is going
> to use those same routines, get_swap_page(), and add_to_swap_cache(). 
> Though examining these two routines in detail and what they call in turn
> would help to verify that expectation.
> 
> Then continue using lxr.linux.no to see what else, if anything, calls
> this pair of routines: get_swap_page(), and add_to_swap_cache().
> 
> This will lead you to any other paths, if any, to swapping a page.
> 
> -- 
>                           I won't rest till it's the best ...
>                           Programmer, Linux Scalability
>                           Paul Jackson <pj@sgi.com> 1.650.933.1373
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

-- 
Eugene TEO   <eugeneteo@despammed.com>   <http://www.anomalistic.org/>
1024D/14A0DDE5 print D851 4574 E357 469C D308  A01E 7321 A38A 14A0 DDE5
main(i) { putchar(182623909 >> (i-1) * 5&31|!!(i<7)<<6) && main(++i); }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
