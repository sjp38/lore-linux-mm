From: Roger Larsson <roger.larsson@norran.net>
Date: Sat, 18 Nov 2000 00:13:29 +0100
Content-Type: text/plain;
  charset="iso-8859-1"
References: <LAW-F137bdkSmLAztxc000006da@hotmail.com>
In-Reply-To: <LAW-F137bdkSmLAztxc000006da@hotmail.com>
Subject: Re: questions about LRU
MIME-Version: 1.0
Message-Id: <00111800132900.01321@dox>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Min San Co <mc343@hotmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 18 November 2000 00:02, Min San Co wrote:
> Hi!
>
> I am trying to implement the LRU page replacement scheme (Least-Recently
> Used).  My idea is to what create a queue that contains pointers to every
> page held by every process in the system.  This queue should be sorted to
> reflect the most recently used pages, which should be at the front.  I am
> thinking of manipulating this list on every timer interrupt (ie 10 msec).

pages are already placed in a ring using the page struct field lru(!)

> After every interrupt, the ordering of pages on the queue will be updated
> based on what pages have been accessed since the last timer interrupt.  I
> am thinking of using the reference bit to determine which page has been
> accessed since the last timer interrupt.  The pages that have been recently
> used will be moved to the front of the queue.

This will not scale - think about 64GB machines... You would need to scan all
pages every timer interrupt...

>
> Any ideas on where to put the queue?
>
Use the existing queues - like active_list (introduced in 2.4.0-test9)
It is scanned but slower than you suggest...

> Cheers!
>
> Max C.
>
> _________________________________________________________________________
> Get Your Private, Free E-mail from MSN Hotmail at http://www.hotmail.com.
>
> Share information about yourself, create your own public profile at
> http://profiles.msn.com.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

-- 
--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
