Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA00027
	for <linux-mm@kvack.org>; Wed, 20 Jan 1999 13:47:07 -0500
Subject: Re: Alpha quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net> <199901191515.PAA05462@dax.scot.redhat.com> <m1ognuvvwu.fsf@flinx.ccr.net>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 20 Jan 1999 19:46:57 +0100
In-Reply-To: ebiederm+eric@ccr.net's message of "20 Jan 1999 08:52:33 -0600"
Message-ID: <87hftllr32.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ebiederm+eric@ccr.net (Eric W. Biederman) writes:

[snip]
> 
> 2) You can walk the page tables very fast.  
>    Not fast enough to want to walk all of the pages for a single call of try to free pages.
>    But fast enough to refill the dirty list.
> 

Ha, ha. That comment reminded me of the times when I tried to walk all
of the page tables in a single call to swapout. I knew it wouldn't
work well, nor I was sure I'll be able to write such a code and have a 
working system, but...

It actually worked, only the system got so DOG SLOW, I couldn't
believe. :)

In fact that's all I wanted to know, how much time is needed to scan
the page tables, so I could compare that to setup we use now (and some
imaginary logic I'll write one day in this or the next century :)).
And, of course, I wanted to learn few new bits and pieces of MM
internals, while writing the code.

For those mathematically challenged, whenever system got into memory
squeeze (almost all the time), it started spending 95% - 99% of CPU,
and swapout speed was few tens (at max) of KB's per second. :)

[snip]
> p.s.
> Since I'm getting some interest, here is my patch with all known
> bugs fixed.  It doesn't work well but it isn't broken.
> 

I very much appreciate people sending new code/patches. It is
interesting for testing or sometimes simply looking and meditating on
other people's ideas, so go ahead and send your patches, you're
welcome.

Unfortunately, I haven't tested your previous patch, only because I
was in the middle of testing my swaplock removal impact. Other MM
changes would have introduced a new variable in the testing, and I
wanted to avoid that.

But, I'm surely going to test your patch in some time.

Regards,
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
