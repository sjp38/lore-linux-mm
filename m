Message-ID: <3918C28B.3B820E6F@norran.net>
Date: Wed, 10 May 2000 03:59:39 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: A possible winner in pre7-8
References: <Pine.LNX.4.10.10005082332560.773-100000@penguin.transmeta.com>
		<3917C33F.1FA1BAD4@sgi.com> <yttln1jtyqg.fsf@vexeta.dc.fi.udc.es>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Since everyone is testing shrink_mmap...

Here is my latest version.

(Currently I have some problems with pre-version
 I am kind of out of synch...)

It should compile, but it is not tested:
- lack of HD, courage, backups...


/RogerL




"Juan J. Quintela" wrote:
> 
> >>>>> "rajagopal" == Rajagopal Ananthanarayanan <ananth@sgi.com> writes:
> 
> Hi
> 
> rajagopal> Interesting! This stuff is coming out faster than I can patch.
> rajagopal> In any case, good news about pre7-8: not only does dbench run without
> rajagopal> errors, but it runs well. Let's hope that others (Juan & Benjamin to name two)
> rajagopal> see similar results.
> 
> No way, here my tests run two iterations, and in the second iteration
> init was killed, and the system become unresponsive (headless machine,
> you know....).  I have no time now to do a more detailed report, more
> information later today.
> 
> Later, Juan.
> 
> --
> In theory, practice and theory are the same, but in practice they
> are different -- Larry McVoy
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
