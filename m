Message-ID: <40523B6C.7070409@matchmail.com>
Date: Fri, 12 Mar 2004 14:36:28 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.6.4-rc2-mm1: vm-split-active-lists
References: <OF62A00090.6117DDE8-ON86256E55.004FED23@raytheon.com> <4051D39D.80207@cyberone.com.au> <20040312193547.GD18799@mail.shareable.org> <405228DC.1010107@matchmail.com> <20040312222139.GG18799@mail.shareable.org>
In-Reply-To: <20040312222139.GG18799@mail.shareable.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Nick Piggin <piggin@cyberone.com.au>, Mark_H_Johnson@raytheon.com, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.c.p@wolk-project.de, owner-linux-mm@kvack.org, plate@gmx.tm, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Jamie Lokier wrote:
> Mike Fedyk wrote:
> 
>>That would have other side benefits.  If the anon page matches (I'm not 
>>calling it "!dirty" since that might have other semantics in the current 
>>VM) what is in swap, it can be cleaned without performing any IO.  Also, 
>> suspending will have much less IO to perform before completion.
> 
> 
> Exactly those sort of benefits.

:)

> 
> Btw, When you say "You're saying all anon memory should become
> swap_cache eventually" it's worth noting that there are benefits to
> doing it the other way too: speculatively pulling in pages that are
> thought likely to be good for interactive response, at the expense of
> pages which have been used more recently, and must remain in RAM for a
> short while while they are considered in use, but aren't ranked so
> highly based on some interactivity heuristics.
> 

IIUC, the current VM loses the aging information as soon as a page is 
swapped out.  You might be asking for a LFU list instead of a LRU list.
Though, a reverse LFU (MFU -- most frequently used?) used only for swap 
might do what you want also...

> I.e. fixing the "everything swapped out in the morning" problem by
> having a long term slow rebalancing in favour of pages which seem to
> be requested for interactive purposes, competing against the short
> term balance of whichever pages have been used recently or are
> predicted by short term readahead.
> 

There was talk in Andrea's objrmap thread about using two LRU lists, but 
I forget what the benefits of that were.

> Both replicating RAM pages to swap, and replicating swap or
> file-backed pages to RAM can be speculative and down slowly, over the
> long term, and when there is little other activity or I/O.

In short, that probably would require some major surgery in the VM.

Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
