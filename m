Received: from mail.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA24660
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 22:06:22 -0500
Subject: Re: Alpha quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net> <199901191515.PAA05462@dax.scot.redhat.com> <m1ognuvvwu.fsf@flinx.ccr.net> <87hftllr32.fsf@atlas.CARNet.hr>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 24 Jan 1999 19:40:23 -0600
In-Reply-To: Zlatko Calusic's message of "20 Jan 1999 19:46:57 +0100"
Message-ID: <m1ww2cuo3c.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

ZC> ebiederm+eric@ccr.net (Eric W. Biederman) writes:
ZC> [snip]
>> 
>> 2) You can walk the page tables very fast.  
>> Not fast enough to want to walk all of the pages for a single call of try to free pages.
>> But fast enough to refill the dirty list.
>> 

ZC> Ha, ha. That comment reminded me of the times when I tried to walk all
ZC> of the page tables in a single call to swapout. I knew it wouldn't
ZC> work well, nor I was sure I'll be able to write such a code and have a 
ZC> working system, but...

ZC> It actually worked, only the system got so DOG SLOW, I couldn't
ZC> believe. :)

ZC> In fact that's all I wanted to know, how much time is needed to scan
ZC> the page tables, so I could compare that to setup we use now (and some
ZC> imaginary logic I'll write one day in this or the next century :)).
ZC> And, of course, I wanted to learn few new bits and pieces of MM
ZC> internals, while writing the code.

ZC> For those mathematically challenged, whenever system got into memory
ZC> squeeze (almost all the time), it started spending 95% - 99% of CPU,
ZC> and swapout speed was few tens (at max) of KB's per second. :)

Well this actually comes much closer to my experience than I like.
My first mistake was to trust the times on the syslog entry as something
reasonbly close to the truth.  Nope.

After I put jiffy counters on my debug messages the results I got changed noticeably.
In particular.  Normally a page table scan is just a couple of jiffies.

But occasionally when I had a lot of dirty pages (16M out of 32M), I was having page table scans
take about 15 seconds per scan.

It may just be that my logic per page table entry was just too expensive.
I'm going to investigate that, and with luck that will be the case,
otherwise I'm going to start seriously considering reverse page table entries.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
