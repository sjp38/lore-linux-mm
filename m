From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
Date: Tue, 9 Oct 2007 19:31:51 +1000
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org> <200710090117.47610.nickpiggin@yahoo.com.au> <alpine.LFD.0.999.0710090750020.5039@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0710090750020.5039@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710091931.51564.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 10 October 2007 00:52, Linus Torvalds wrote:
> On Tue, 9 Oct 2007, Nick Piggin wrote:
> > I have done some tests which indicate a couple of very basic common tools
> > don't do much zero-page activity (ie. kbuild). And also combined with
> > some logical arguments to say that a "sane" app wouldn't be using
> > zero_page much. (basically -- if the app cares about memory or cache
> > footprint and is using many pages of zeroes, then it should have a more
> > compressed representation of zeroes anyway).
>
> One of the things that zero-page has been used for is absolutely *huge*
> (but sparse) arrays in Fortan programs.
>
> At least in traditional fortran, it was very hard to do dynamic
> allocations, so people would allocate the *maximum* array statically, and
> then not necessarily use everything. I don't know if the pages ever even
> got paged in,

In which case, they would not be using the ZERO_PAGE?
If they were paging in (ie. reading) huge reams of zeroes,
then maybe their algorithms aren't so good anyway? (I don't
know).


> but this is the kind of usage which is *not* insane. 

Yeah, that's why I use the double quotes... I wonder how to
find out, though. I guess I could ask SGI if they could ask
around -- but that still comes back to the problem of not being
able to ever conclusively show that there are no real users of
the ZERO_PAGE.

Where do you suggest I go from here? Is there any way I can
convince you to try it? Make it a config option? (just kidding)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
