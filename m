From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
Date: Tue, 9 Oct 2007 20:15:07 +1000
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org> <200710091931.51564.nickpiggin@yahoo.com.au> <alpine.LFD.0.999.0710091917410.3838@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0710091917410.3838@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710092015.07741.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 10 October 2007 12:22, Linus Torvalds wrote:
> On Tue, 9 Oct 2007, Nick Piggin wrote:
> > Where do you suggest I go from here? Is there any way I can
> > convince you to try it? Make it a config option? (just kidding)
>
> No, I'll take the damn patch, but quite frankly, I think your arguments
> suck.
>
> I've told you so before, and asked for numbers, and all you do is

I gave 2 other numbers. After that, it really doesn't matter if I give
you 2 numbers or 200, because it wouldn't change the fact that there
are 3 programs using the ZERO_PAGE that we'll never know about.


> handwave. And this is like the *third*time*, and you don't even seem to
> admit that you're handwaving.

I think I've always admitted I'm handwaving in my assertion that programs
would not be using the zero page. My handwaving is an attempt to show that
I have some vaguely reasonable reasons to think it will be OK to remove it.
That's all.


> So let's do it, but dammit:
>  - make sure there aren't any invalid statements like this in the final
>    commit message.

Was the last one OK?


>  - if somebody shows that you were wrong, and points to a real load,
>    please never *ever* make excuses for this again, ok?
>
> Is that a deal? I hope we'll never need to hear about this again, but I
> really object to the way you've tried to "sell" this thing, by basically
> starting out dishonest about what the problem was,

The dishonesty in the changelog is more of an oversight than an attempt
to get it merged. It never even crossed my mind that you would be fooled
by it ;) To prove my point: the *first* approach I posted to fix this
problem was exactly a patch to special-case the zero_page refcounting
which was removed with my PageReserved patch. Neither Hugh nor yourself
liked it one bit!

So I have no particular bias against the zero page or problem admitting
I introduced the issue. I do just think this could be a nice opportunity
to try getting rid of the zero page and simplifiy things.


> and even now I've yet 
> to see a *single* performance number even though I've asked for them
> (except for the problem case, which was introduced by *you*)

Basically: I don't know what else to show you! I expect it would be
relatively difficult to find a measurable difference between no zero-page
and zero-page with no refcounting problem. Precisely because I can't
find anything that really makes use of it. Again: what numbers can I
get for you that would make you feel happier about it?

Anyway, before you change your mind: it's a deal! If somebody screams
then I'll have a patch for you to reintroduce the zero page minus
refcounting the next day.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
