Date: Sun, 26 Dec 2004 15:12:45 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free
 maps
In-Reply-To: <87wtv464ty.fsf@deneb.enyo.de>
Message-ID: <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org>
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <fa.n04s9ar.17sg3f@ifi.uio.no>
 <E1ChwhG-00011c-00@be1.7eggert.dyndns.org> <87wtv464ty.fsf@deneb.enyo.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: 7eggert@gmx.de, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 27 Dec 2004, Florian Weimer wrote:
> 
> But overwritting with zeros is commonly called "scrubbing", as in
> "password scrubbing".

On the other hand, "memory scrubbing" in an OS sense is most often used
for reading and re-writing the same thing to fix correctable ECC failures.

Anyway, at this point I think the most interesting question is whether it 
actually improves any macro-benchmark behaviour, rather than just a page 
fault latency tester microbenchmark..

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
