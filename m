Message-Id: <l03130320b7459cd17e98@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0106071345190.6604-100000@penguin.transmeta.com>
References: <Pine.LNX.4.21.0106071330060.6510-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 7 Jun 2001 22:08:00 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: Background scanning change on 2.4.6-pre1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > This is going to make all pages have age 0 on an idle system after some
>> > time (the old code from Rik which has been replaced by this code tried to
>> > avoid that)
>
>There's another reason why I think the patch may be ok even without any
>added logic: not only does it simplify the code and remove a illogical
>heuristic, but there is nothing that really says that "age 0" is
>necessarily very bad.

Here's my take on it.  The point of ageing is twofold - to age down pages
that aren't in use, and to age up pages that *are* in use.  So, pages that
are in use will remain with high ages even when background scanning is
being done, and pages that aren't in use will decay to zero age.

I can't see what's wrong with that.  When we need more memory, it's a Very
Good Thing to know that most of the pages in the system haven't been
accessed in yonks - we know exactly which ones we want to throw out first.

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
