Date: Mon, 16 Apr 2001 19:12:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
In-Reply-To: <l03130300b701154d843c@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0104161912340.14442-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Apr 2001, Jonathan Morton wrote:

> >Ideally, I'd SIGSTOP each thrashing process. That way, enough
> >processes can be swapped out and KEPT swapped out to allow others to
> >complete their task, freeing up physical memory. Then you can SIGCONT
> >the processes you suspended, and make progress that way. There are
> >risks of "deadlocks", of course - suspend X, and all your graphical
> >apps will lock up waiting for it. This should lower VM pressure enough
> >to cause X to be restarted, though...
> 
> Strongly agree.  Two points that need defining for this:
> 
> - When does a process become "thrashing"?  Clearly paging-in in itself is
> not a good measure, since all processes do this at startup - paging-in
> which forces other memory out, OTOH, is a prime target.
> 
> - How long do we suspend it for?  Does this depend on how many times it's
> been suspended recently?

I'm already working on something like this. 

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
