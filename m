Date: Wed, 28 May 2008 23:24:48 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] Re: bad pmd ffff810000207238(9090909090909090).
In-Reply-To: <20080528204356.GA12687@1wt.eu>
Message-ID: <alpine.LNX.1.10.0805282321050.19264@fbirervta.pbzchgretzou.qr>
References: <483CBCDD.10401@lugmen.org.ar> <Pine.LNX.4.64.0805281922530.7959@blonde.site> <20080528195637.GA11662@1wt.eu> <alpine.LNX.1.10.0805282210580.19264@fbirervta.pbzchgretzou.qr> <20080528204356.GA12687@1wt.eu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Hugh Dickins <hugh@veritas.com>, Fede <fedux@lugmen.org.ar>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 2008-05-28 22:43, Willy Tarreau wrote:
>> >
>> >Is there a particular reason we use 0x90 as an alignment filler ?
>> 
>> Alignment within functions. You could use a JMP to jump over
>> the alignment, but that would be costly. So in order to
>> "run through the wall", you need an opcode that does not
>> do anything, something like 0x90.
>> 0xAF would map to scasd on x86, and I'd hardly call that a
>> no-op.
>
>OK, I did not understand from Hugh's explanation that it was
>all about alignment within functions. Of course, 0x90 is fine
>there (though there are multi-byte NOPs available).

"All about alignment within functions" -- I am not sure about that,
you just happened to ask about 0x90 :)
And if you have a 1-byte NOP (which fits perfectly everywhere),
which is also a real NOP (and not just a filler byte that could
possibly be an opcode doing something very different), you've
got an ideal candidate for padding, no?
There is probably nothing wrong with padding .data sections
with 0xAF or even 0xDB and ud2 to catch execute-readonly-data
cases. To that end, I think something like that should be
proposed to binutils.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
