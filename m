Message-ID: <396B8A38.D7FF17B5@norran.net>
Date: Tue, 11 Jul 2000 22:57:28 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
References: <Pine.LNX.4.21.0007111938241.3644-100000@inspiron.random> <ytt8zv8mt61.fsf@serpe.mitica>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Juan J. Quintela" wrote:
> 
> >>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:
> 
> andrea> On Tue, 11 Jul 2000, Rik van Riel wrote:
> >> No. You just wrote down the strongest argument in favour of one
> >> unified queue for all types of memory usage.
> 
> andrea> Do that and download an dozen of iso image with gigabit ethernet in
> andrea> background.
> 
> With Gigabit etherenet, the pages that you are coping will never be
> touched again -> that means that its age will never will increase,
> that means that it will only remove pages from the cache that are
> younger/have been a lot of time without being used.  That looks quite
> ok to me.  Notice that the fact that the pages came from the Gigabit
> ethernet makes no diference that if you copy from other medium.  Only
> difference is that you will get them only faster.
> 

Problem is that you have to age all pages, at some point the newly read
pages will be older than the almost never reused ones.

Note: You can not avoid ageing all pages. If not an easy attack would be
to reread some pages over and over... (they would never go away...)

Someone mentioned the 2Q algorithm earlier - pages had to prove
themselves
to get added in the first place. Interesting approach.

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
