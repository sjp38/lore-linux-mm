Message-Id: <l0313030fb743f99e010e@[192.168.239.105]>
In-Reply-To: <3B1E2C3C.55DF1E3C@uow.edu.au>
References: <3B1E203C.5DC20103@uow.edu.au>,	
 <l03130308b7439bb9f187@[192.168.239.105]>
 <l0313030db743d4a05018@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 6 Jun 2001 17:44:44 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> >So the more users, the more slowly it ages.  You get the idea.
>>
>> However big you make that scaling constant, you'll always find some pages
>> which have more users than that.
>
>2^24?

True, you aren't going to find 16 million processes on a box anytime soon.
However, it still doesn't quite appeal to me - it looks too much like a
hack.  What happens if, by some freak, someone does build a machine which
can handle that much?  Consider some future type of machine which is
essentially a Beowulf cluster with a single address space - I imagine NUMA
machines are already approaching this size.

>> BUT, as it turns out, refill_inactive_scan() already does ageing down on a
>> page-by-page basis, rather than process-by-process.
>
>Yes.  page->count needs looking at if you're doing physically-addressed
>scanning.  Rik's patch probably does that.

Explain...

AFAICT, the scanning in refill_inactive_scan() simply looks at a list of
pages, and doesn't really do physical addresses.  The age of a page should
be independent on the number of mappings it has, but dependent instead on
how much it is used (or how long it is not used for).  That code already
exists, and it works.

Also, I just sat down for a few minutes and figured out a very simple way
to get a proper working-set calculation without the fuss...  'course I have
to test it first.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
