Date: Sun, 14 Nov 2004 09:25:25 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Possible alternate 4 level pagetables?
Message-ID: <20041114082525.GB16795@wotan.suse.de>
References: <4196F12D.20005@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4196F12D.20005@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2004 at 04:46:21PM +1100, Nick Piggin wrote:
> Just looking at your 4 level page tables patch, I wondered why the extra
> level isn't inserted between pgd and pmd, as that would appear to be the
> least intrusive (conceptually, in the generic code). Also it maybe matches
> more closely the way that the 2->3 level conversion was done.

I did it the way I did to keep i386 and other archs obviously correct 
because their logic doesn't change at all for the three lower levels,
and the highest level just hands a pointer through.

Regarding intrusiveness in common code: you pretty much have to change
most of of mm/memory.c, no matter what you do. Also there are overall
only 7 or 8 users that really need the full scale changes, so 
it's not as bad as it looks. Ok there is ioremap in each architecture,
but usually you can cheat for these because you know the architecture
will never support 4levels.

I'm sorry, but I don't see much advantage of your patches over mine.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
