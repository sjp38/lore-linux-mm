Subject: Re: inconsistent do_gettimeofday for copy_page
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20040310111919.83754.qmail@web10901.mail.yahoo.com>
References: <20040310111919.83754.qmail@web10901.mail.yahoo.com>
Content-Type: text/plain
Message-Id: <1078918542.9745.91.camel@gaston>
Mime-Version: 1.0
Date: Wed, 10 Mar 2004 22:35:42 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashwin Rao <ashwin_s_rao@yahoo.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2004-03-10 at 22:19, Ashwin Rao wrote:
> For calculating the time required to copy_page i tried
> the do_gettimeofday for 1000 pages in a loop. But as
> the number of pages changes the time required varies
> non-linearly.

That's expected, unless you have no cache ;) Then you also
have the TLB misses..

> I also tried reading xtime and using monotonic_clock
> but they didnt help either. For do_gettimeof day for a
> single invocation of copy_page on a pentium 4 gave me
> 10 microsecs but when invoked for a 1000 pages the
> time required was 750ns per page.
> Is there some way of finding out the exact time
> required for copying a page.

No. It depends mostly on cache effects and bus usage, though
you can probably get good approximation for both the cases
where everything is in the cache on both sides of the copy,
and when you are in the worst case scenario of cold cache
or larger copy than the cache.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
