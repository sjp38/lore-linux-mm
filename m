Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id B094F16B19
	for <linux-mm@kvack.org>; Sun, 18 Mar 2001 04:37:22 -0300 (EST)
Date: Sun, 18 Mar 2001 04:23:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: changing mm->mmap_sem  (was: Re: system call for process
 information?)
In-Reply-To: <20010316125338.L30889@redhat.com>
Message-ID: <Pine.LNX.4.21.0103180419550.13050-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: george anzinger <george@mvista.com>, Alexander Viro <viro@math.psu.edu>, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Mar 2001, Stephen C. Tweedie wrote:

> Right, I'm not suggesting removing that: making the mmap_sem
> read/write is fine, but yes, we still need that semaphore.

Initial patch (against 2.4.2-ac20) is available at
http://www.surriel.com/patches/

> But as for the "page faults would use an extra lock to protect against
> each other" bit --- we already have another lock, the page table lock,
> which can be used in this way, so ANOTHER lock should be unnecessary.

Tomorrow I'll take a look at the various ->nopage
functions and do_swap_page to see if these functions
would be able to take simultaneous faults at the same
address (from multiple threads).  If not, either we'll
need to modify these functions, or we could add a (few?)
extra lock to prevent these functions from faulting at
the same address at the same time in multiple threads.

regards,

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
