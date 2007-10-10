Date: Wed, 10 Oct 2007 08:04:29 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
In-Reply-To: <200710100030.28806.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.0.999.0710100758460.3838@woody.linux-foundation.org>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0710100424050.24074@blonde.wat.veritas.com>
 <alpine.LFD.0.999.0710092202000.3838@woody.linux-foundation.org>
 <200710100030.28806.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 10 Oct 2007, Nick Piggin wrote:
> 
> It just seems like now might be a good time to just _try_ removing
> the zero page

Yes. Let's do your patch immediately after the x86 merge, and just see if 
anybody screams. 

It might take a while, because I certainly agree that whoever would be 
affected by it is likely to be unusual.

> OK, maybe this is where we are not on the same page.
> There are 2 issues really. Firstly, performance problem of
> refcounting the zero-page -- we've established that it causes
> this livelock and that we should stop refcounting it, right?

Yes, I do agree that refcounting is problematic. 

> Second issue is the performance difference between removing the
> zero page completely, and de-refcounting it (it's obviously
> incorrect to argue for zero page removal for performance reasons
> if the performance improvement is simply coming from avoiding
> the refcounting).

Well, even if it's a "when you don't get into the bad behaviour, 
performance difference is not measurable", and give a before-and-after 
number for some random but interesting load. Even if it's just a kernel 
compile..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
