Message-ID: <3911F9CF.681E96DA@norran.net>
Date: Fri, 05 May 2000 00:29:35 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] Alternate shrink_mmap
References: <Pine.LNX.4.21.0005041557390.23740-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 4 May 2000, Roger Larsson wrote:
> 
> > Yes, I start scanning in the beginning every time - but I do not
> > think that is so bad here, why?
> 
> Because you'll end up scanning the same few pages over and
> over again, even if those pages are used all the time and
> the pages you want to free are somewhere else in the list.

Not really since priority is decreased too...
Next time the double amount of pages is scanned, and the oldest are
always scanned.

> 
> > a) It releases more than one page of the required zone before returning.
> > b) It should be rather fast to scan.
> >
> > I have been trying to handle the lockup(!), my best idea is to
> > put in an artificial page that serves as a cursor...
> 
> You have to "move the list head".

Hmm,

If the list head is moved your oldest pages will end up at top,
not that good.
I do not want to resort the list for any reason other than
page use!
Currently I try to compile another version of my patch.

I think it has been mentioned before when finding young pages and
moving them up you probably need to scan the whole list.

An interesting and remaining issue:
* What happens if you read a lot of new pages from disk.
  Read only once, but too many to fit in memory...
- Should pages used many times be rewarded?

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
