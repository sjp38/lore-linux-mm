Date: Wed, 17 May 2000 22:07:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
In-Reply-To: <yttwvksvhqb.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0005172205050.3951-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 18 May 2000, Juan J. Quintela wrote:

>         after some more testing we found that:
> 1- the patch works also with mem=32MB (i.e. it is a winner also for
>    low mem machines)
> 2- Interactive performance looks great, I can run an mmap002 with size
>    96MB in an 32MB machine and use an ssh session in the same machine
>    to do ls/vi/... without dropouts, no way I can do that with
>    previous pre-*
> 3- The system looks really stable now, no more processes killed for
>    OOM error, and we don't see any more fails in do_try_to_free_page.

I am now testing the patch on my small test machine and must
say that things look just *great*. I can start up a gimp while
bonnie is running without having much impact on the speed of
either.

Interactive performance is nice and stability seems to be
great as well.

I'll test it on my 512MB test machine as well and will have
more test results tomorrow. This patch is most likely good
enough to include in the kernel this night ;)

(and even if it isn't, it's a hell of a lot better than
anything we had before)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
