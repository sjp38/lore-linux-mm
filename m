From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free maps
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <fa.n04s9ar.17sg3f@ifi.uio.no>
	<E1ChwhG-00011c-00@be1.7eggert.dyndns.org>
	<87wtv464ty.fsf@deneb.enyo.de>
	<Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org>
Date: Mon, 27 Dec 2004 00:24:56 +0100
In-Reply-To: <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org> (Linus
	Torvalds's message of "Sun, 26 Dec 2004 15:12:45 -0800 (PST)")
Message-ID: <87llbk63sn.fsf@deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: 7eggert@gmx.de, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Linus Torvalds:

> Anyway, at this point I think the most interesting question is whether it 
> actually improves any macro-benchmark behaviour, rather than just a page 
> fault latency tester microbenchmark..

By the way, some crazy idea that occurred to me: What about
incrementally scrubbing a page which has been assigned previously to
this CPU, while spinning inside spinlocks (or busy-waiting somewhere
else)?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
