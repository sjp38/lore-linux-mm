Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id DC55416B39
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 16:13:02 -0300 (EST)
Date: Thu, 19 Apr 2001 16:13:02 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <15790000.987706428@baldur>
Message-ID: <Pine.LNX.4.33.0104191609500.17635-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmc@austin.ibm.com>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Dave McCracken wrote:
> --On Thursday, April 19, 2001 19:47:12 +0100 "James A. Sutherland"
> <jas88@cam.ac.uk> wrote:
>
> > Well, it was my proposal when I first said it :-)
>
> Oops.  My apologies.  I'd lost track of whose idea it was originally :)

Actually, this idea must have been in Unix since about
Bell Labs v5 Unix, possibly before.

And when paging was introduced in 3bsd, process suspension
under heavy load was preserved in the system to make sure
the system would continue to make progress under heavy
load instead of thrashing to a halt.

This is not a new idea, it's an old solution to an old
problem; it even seems to work quite well.

Incidentally, the "minimal working set" idea Stephen posted
was also in 3bsd. Since this idea is good for preserving the
forward progress of smaller programs and is extremely simple
to implement, we probably want this too.

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
