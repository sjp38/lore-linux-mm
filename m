Date: Fri, 23 Jun 2000 20:11:09 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
In-Reply-To: <200006222022.NAA47942@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0006232004160.1280-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Timur Tabi <ttabi@interactivesi.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000, Kanoj Sarcar wrote:

>Umm, careful. If you happen to share a cacheline between a readonly array 
>and a frequently updated variable, it might be better not to delete
>unused elements from an array - that way, you might be able to bunch up
>all the frequently updated variables into their own cacheline, and save
>the memory write back of an extra cacheline.

I think on UP we shouldn't protect any read-only memory against somebody
that isn't optimized. I think if there are a set of frequently updated
variables, _they_ should care to live in the same cacheline (and they
could also include in the same cacheline other stuff of course). It
shouldn't be the gfpmask_zone array (that is read only) that cares to not
include other stuff because there could be something not well optimized
for cacheline flushes.

>BTW, this is all of course nitpicking.

Oh indeed but it's fun ;-)

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
