Date: Mon, 25 Jul 2005 08:59:57 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: PageReserved removal from swsusp
Message-ID: <20050725065957.GA6148@elf.ucw.cz>
References: <42E44294.5020408@yahoo.com.au> <1122265909.6144.106.camel@localhost> <42E46FF5.5080805@yahoo.com.au> <42E4852D.7010209@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42E4852D.7010209@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: ncunningham@cyclades.com, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi!

> >I'm currently playing around with trying to reuse an existing flag
> >to get this information (instead of PageReserved). But it doesn't seem
> >like a big problem if we have to fall back to the above.
> >
> 
> OK, with the attached patch (on top of the PageReserved removal patches)
> things work nicely. However I'm not sure that I really like the use of
> flags == 0xffffffff to indicate the page is unusable. For one thing it
> may confuse things that walk physical pages, and for another it can
> easily break if someone clears a flag of an 'unusable' page.

No compains from my part....

Another solution may be to use PageReserved as kind of "shift".

I.e. PageNosave == PageReserved | PageLocked, PageNosaveFree ==
PageReserved | PageFree or something like that....
								Pavel
-- 
teflon -- maybe it is a trademark, but it should not be.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
