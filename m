Date: Tue, 22 Oct 2002 22:19:37 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
In-Reply-To: <20021022184938.A2395@infradead.org>
Message-ID: <Pine.LNX.4.44.0210222204330.21530-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Oct 2002, Christoph Hellwig wrote:

> what is the reason for that interface?  It looks like a gross
> performance hack for misdesigned applications to me, kindof windowsish..

there are a number of reasons why we very much want this extension to the
Linux VM. Please catch up with the full email discussion, check out the
first announcement of the interface to lkml, the subject of the email was:
"[patch, feature] nonlinear mappings, prefaulting support, 2.5.42-F8".

(and add one more application category to the list of beneficiaries,
NPTL-style threading libraries, see the "[patch] mmap-speedup-2.5.42-C3"  
discussion on lkml.)

I think it is quite a bit architectural step for the Linux VM to have more
generic vmas that 1) can be nonlinear 2) can have finegrained, non-uniform
protection bits. It has been clearly established in the past few years
empirically that the vma tree approach itself sucks performance-wise for
applications that have many different mappings.

And is it a big problem that RAM-windowing applications can make use of
the new capabilities as well, to overcome the limits of 32 bits? Your
response is a bit knee-jerk, what do you think the kernel itself does when
it piggybacks to the highmem range and using kmap? There's no other way to
overcome 32 bitness limits on a box that has much more than 32 bits worth
of RAM, but to start mapping things in dynamically. So what's your point?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
