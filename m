Message-ID: <3911E111.DE0B5CFB@norran.net>
Date: Thu, 04 May 2000 22:44:01 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] Alternate shrink_mmap
References: <Pine.LNX.4.21.0005041524220.23740-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yes, I start scanning in the beginning every time - but I do not think
that is so bad here, why?

a) It releases more than one page of the required zone before returning.
b) It should be rather fast to scan.

I have been trying to handle the lockup(!), my best idea is to put in
an artificial page that serves as a cursor...

/RogerL


Rik van Riel wrote:
> 
> On Thu, 4 May 2000, Roger Larsson wrote:
> 
> > I have noticed (not by running - lucky me) that I break this
> > assumption....
> > /*
> >  * NOTE: to avoid deadlocking you must never acquire the pagecache_lock
> > with
> >  *       the pagemap_lru_lock held.
> >  */
> 
> Also, you seem to start scanning at the beginning of the
> list every time, instead of moving the list head around
> so you scan all pages in the list evenly...
> 
> Anyway, I'll use something like your code, but have two
> lists (an active and an inactive list, like the BSD's
> seem to have).
> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/               http://www.surriel.com/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
