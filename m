Date: Mon, 3 Mar 2003 08:50:34 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] remap-file-pages-2.5.63-A0
In-Reply-To: <Pine.LNX.4.44.0303031142190.24967-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.44.0303030849050.11244-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2003, Ingo Molnar wrote:
> 
> the attached patch, against BK-curr, is a preparation to make
> remap_file_pages() usable on swappable vmas as well. When 'swapping out'
> shared-named mappings the page offset is written into the pte.
> 
> it takes one bit from the swap-type bits, otherwise it does not change the
> pte layout - so it should be easy to adapt any other architecture to this
> change as well. (this patch does not introduce the protection-bits-in-pte
> approach used in my previous patch.)

One question: Why?

What's wrong with just using the value we use now (0), and just 
calculating the page from the vma/offset information? Why hide the offset 
in the page tables, when there is no need for it?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
