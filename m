Date: Wed, 3 Oct 2007 08:21:51 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
In-Reply-To: <200710030345.10026.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.0.999.0710030813090.3579@woody.linux-foundation.org>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <200710030345.10026.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 3 Oct 2007, Nick Piggin wrote:
> 
> I don't know if Linus actually disliked the patch itself, or disliked
> my (maybe confusingly worded) rationale?

Yes. I'd happily accept the patch, but I'd want it clarified and made 
obvious what the problem was - and it wasn't the zero page itself, it was 
a regression in the VM that made it less palatable.

I also thought that there were potentially better solutions, namely to 
simply avoid the VM regression, but I also acknowledge that they may not 
be worth it - I just want them to be on the table.

In short: the real cost of the zero page was the reference counting on the 
page that we do these days. For example, I really do believe that the 
problem could fairly easily be fixed by simply not considering zero_page
to be a "vm_normal_page()". We already *do* have support for pages not 
getting ref-counted (since we need it for other things), and I think that 
zero_page very naturally falls into exactly that situation.

So in many ways, I would think that turning zero-page into a nonrefcounted 
page (the same way we really do have to do for other things anyway) would 
be the much more *direct* solution, and in many ways the obvious one.

HOWEVER - if people think that it's easier to remove zero_page, and want 
to do it for other reasons, *AND* can hopefully even back up the claim 
that it never matters with numbers (ie that the extra pagefaults just make 
the whole zero-page thing pointless), then I'd certainly accept the patch. 

I'd just want the patch *description* to then also be correct, and blame 
the right situation, instead of blaming zero-page itself.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
