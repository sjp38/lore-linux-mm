Message-ID: <39C806D8.7A600DA5@norran.net>
Date: Wed, 20 Sep 2000 02:37:44 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: Freezes with test9-pre4 + mmap002
References: <yttg0mwaqg2.fsf@serpe.mitica>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Juan J. Quintela" wrote:
> 
> Hi
>         while I am running mmap002 in test9-pre4 I got the computer
>         frozen, it don't answer to my open windows anymore, it answers
>         only to pings.  I have got the attached traces.  The machine
>         is SMP with IDE disks.

I run from command line. No X-windows.
UP (= not SMP nor UP specific) with IDE disks.

(got the same problem with test9-pre2, upgraded and retested)

> 
>         I had no additional/local patches applied.

Me too.



As I reported earlier it looks like pages are ping ponged between
Active and inactive_dirty (the sum is always the same!)
inactive_clean is zero (always)
slab contains very few pages.

Hope this info helps.

/RogerL



--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
