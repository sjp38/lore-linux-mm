Subject: Re: pre2 swap_out() changes
References: <Pine.LNX.4.10.10101111046020.2388-100000@penguin.transmeta.com>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 12 Jan 2001 12:35:32 +0100
In-Reply-To: Linus Torvalds's message of "Thu, 11 Jan 2001 10:49:10 -0800 (PST)"
Message-ID: <87itnlovej.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On Thu, 11 Jan 2001, Marcelo Tosatti wrote:
> > 
> > Since no process calls swap_out() directly, I dont see any sense on the
> > comment above. 
> 
> Stage #2 is to allow them to call refill_inactive() in the low-memory case
> (right now processes can only do "page_launder()" in alloc_pages(), and I
> think that is wrong - it means that the only one scanning page tables etc
> is kswapd)
> 

Performance of 2.4.0-pre2 is terrible as it is now. There is a big
performance drop from 2.4.0. Simple test (that is not excessively
swapping, I remind) shows this:

2.2.17     -> make -j32  392.49s user 47.87s system 168% cpu 4:21.13 total
2.4.0      -> make -j32  389.59s user 31.29s system 182% cpu 3:50.24 total
2.4.0-pre2 -> make -j32  393.32s user 138.20s system 129% cpu 6:51.82 total

-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
