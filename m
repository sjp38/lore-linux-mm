Message-ID: <XFMail.20001010071013.peterw@mulga.surf.ap.tivoli.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.21.0010092256070.9803-100000@elte.hu>
Date: Tue, 10 Oct 2000 07:10:13 +1000 (EST)
From: Peter Waltenberg <peterw@dascom.com.au>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: MM mailing list <linux-mm@kvack.org>, Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 09-Oct-2000 Ingo Molnar wrote:
> 
> On Mon, 9 Oct 2000, Linus Torvalds wrote:
> 
>> I disagree - if we start adding these kinds of heuristics to it, it
>> wil just be a way for people to try to confuse the OOM code. Imagine
>> some bad guy that does 15 fork()'s and then tries to OOM...
> 
> yep.
> 
>       Ingo
> 

People seem to be forgetting (again), that Rik's code is *REALLY* an
OOM killer, i.e. it only kicks in when there is *NO* memory left. If something
isn't killed now, the machine hangs or crashes anyway.

I.e. it isn't a "well in 5 minutes or so we'll be a little short of memory
so lets ask some of these processes to go away killer", it kicks in when there
probably isn't enough RAM left to safely do a printk, let alone pop up a window
asking the user which process he or she wants to sacrifce today.

It's probably reasonable to not kill init, but the rest just don't matter.
Without the OOM killer the machine would have locked up and you'd lose that 3
days of work from the background process. You'd have lost that site you
were looking at with Netscape, (etc).

At least with Rik's code you end up with a usable machine afterwards which is a
major improvement.

If you want "clever" do it in user space, the kernel code should be as simple
as possible.


Peter
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
