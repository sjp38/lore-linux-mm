Date: Tue, 9 Oct 2007 20:06:10 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
In-Reply-To: <200710092015.07741.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.0.999.0710091955100.3838@woody.linux-foundation.org>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <200710091931.51564.nickpiggin@yahoo.com.au>
 <alpine.LFD.0.999.0710091917410.3838@woody.linux-foundation.org>
 <200710092015.07741.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Tue, 9 Oct 2007, Nick Piggin wrote:
> 
> I gave 2 other numbers. After that, it really doesn't matter if I give
> you 2 numbers or 200, because it wouldn't change the fact that there
> are 3 programs using the ZERO_PAGE that we'll never know about.

You gave me no timings what-so-ever. Yes, you said "1000 page faults", but 
no, I have yet to see a *single* actual performance number.

Maybe I missed it? Or maybe you just never did them.

Was it really so non-obvious that I actually wanted *performance* numbers, 
not just some random numbers about how many page faults you have? Or did 
you post them somewhere else? I don't have any memory of having seen any 
performance numbers what-so-ever, but I admittedly get too much email.

Here's three numbers of my own: 8, 17 and 975.

So I gave you "numbers", but what do they _mean_? 

So let me try one more time:

 - I don't want any excuses about how bad PAGE_ZERO is. You made it bad, 
   it wasn't bad before.
 - I want numbers. I want the commit message to tell us *why* this is 
   done. The numbers I want is performance numbers, not handwave numbers. 
   Both for the bad case that it's supposed to fix, *and* for "normal 
   load".
 - I want you to just say that if it turns out that there are people who 
   use ZERO_PAGE, you stop calling them crazy, and promise to look at the 
   alternatives.

How much clearer can I be? I have said several times that I think this 
patch is kind of sad, and the reason I think it's sad is that you (and 
Hugh) convinced me to take the patch that made it sad in the first place. 
It didn't *use* to be bad. And I've use ZERO_PAGE myself for timing, I've 
had nice test-programs that knew that it could ignore cache effects and 
get pure TLB effects when it just allocated memory and didn't write to it.

That's why I don't like the lack of numbers. That's why I didn't like the 
original commit message that tried to blame the wrong part. That's why I 
didn't like this patch to begin with.

But I'm perfectly ready to take it, and see if anybody complains. 
Hopefully nobody ever will.

But by now I absolutely *detest* this patch because of its history, and 
how I *told* you guys what the reserved bit did, and how you totally 
ignored it, and then tried to blame ZERO_PAGE for that. So yes, I want the 
patch to be accompanied by an explanation, which includes the performance 
side of why it is wanted/needed in the first place.

If this patch didn't have that kind of history, I wouldn't give a flying f 
about it. As it is, this whole thing has a background.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
