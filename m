Subject: Re: PATCH: Possible solution to VM problems (take 2)
References: <Pine.LNX.4.21.0005161631320.32026-100000@duckman.distro.conectiva>
	<yttvh0evx43.fsf@vexeta.dc.fi.udc.es>
	<yttn1lox5wa.fsf_-_@vexeta.dc.fi.udc.es>
	<ytt8zx8wy7f.fsf_-_@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "18 May 2000 01:31:32 +0200"
Date: 18 May 2000 02:12:44 +0200
Message-ID: <yttwvksvhqb.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        after some more testing we found that:
1- the patch works also with mem=32MB (i.e. it is a winner also for
   low mem machines)
2- Interactive performance looks great, I can run an mmap002 with size
   96MB in an 32MB machine and use an ssh session in the same machine
   to do ls/vi/... without dropouts, no way I can do that with
   previous pre-*
3- The system looks really stable now, no more processes killed for
   OOM error, and we don't see any more fails in do_try_to_free_page.

Later, Juan.

PD. I will comment the patch tomorrow, I have no more time today,
    sorry about that.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
