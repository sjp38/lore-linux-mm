Date: Wed, 24 Apr 2002 11:50:57 +0100 (BST)
From: Christian Smith <csmith@micromuse.com>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <Pine.LNX.4.44L.0204232145120.1960-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.33.0204241138290.1968-100000@erol>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Apr 2002, Rik van Riel wrote:

>On Tue, 23 Apr 2002, Christian Smith wrote:
>
>> The question becomes, how much work would it be to rip out the Linux MM
>> piece-meal, and replace it with an implementation of UVM?
>
>I doubt we want the Mach pmap layer.

Why not? It'd surely make porting to new architecures easier (not that
I've tried it either way, mind) is there is a clearly defined MMU
interface. Pmap can hide the differences between forward mapping page
table, TLB or inverted page table lookups, can do SMP TLB shootdown 
transparently. If not the Mach pmap layer, then surely another pmap-like 
layer would be beneficial.

It can handle sparse address space management without the hackery of 
n-level page tables, where a couple of years ago, 3 levels was enough for 
anyone, but now we're not so sure.

The n-level page table doesn't fit in with a high level, platform 
independant MM, and doesn't easily work for all classes of low level MMU. 
It doesn't really scale up or down.

Read the papers on UVM at:
 http://www.ccrc.wustl.edu/pub/chuck/tech/uvm

>
>It should be much easier to reimplement the pageout parts of
>the BSD memory management on top of a simpler reverse mapping
>system.

Agreed.

>
>You can get that code at  http://surriel.com/patches/
>
>cheers,
>
>Rik
>

-- 
    /"\
    \ /    ASCII RIBBON CAMPAIGN - AGAINST HTML MAIL 
     X                           - AGAINST MS ATTACHMENTS
    / \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
