Date: Sat, 9 Sep 2000 19:12:24 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: test8-vmpatch performs great here!
In-Reply-To: <20000909100633.A8526@redhat.com>
Message-ID: <Pine.LNX.4.21.0009091911350.1049-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: deprogrammer <ttb@tentacle.dhs.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 Sep 2000, Stephen C. Tweedie wrote:
> On Fri, Sep 08, 2000 at 08:29:43PM -0300, Rik van Riel wrote:
> 
> > >From fs/buffer.c:
> 
> > and in kflushd()
> >    2622                 wake_up(&bdflush_done);
> > 
> > (which wakes up the first task on the wait queue)
> 
> No.  That might be true if we were TASK_EXCLUSIVE, but we are
> not --- *all_ processes on the wait queue will be woken,

> wake_up_all() is only different from wake_up() when you
> encounter TASK_EXCLUSIVE processes.

Indeed, this fooled me. For readability I have changed
the wake_up() to a wake_up_all() anyway ;)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
