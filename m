Date: Mon, 25 Sep 2000 11:06:27 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: refill_inactive()
In-Reply-To: <Pine.LNX.4.21.0009241148100.2789-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0009251102420.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Roger Larsson <roger.larsson@norran.net>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2000, Ingo Molnar wrote:

> i'm wondering about the following piece of code in refill_inactive():
> 
>                 if (current->need_resched && (gfp_mask & __GFP_IO)) {
>                         __set_current_state(TASK_RUNNING);
>                         schedule();
>                 }
> 
> shouldnt this be __GFP_WAIT? It's true that __GFP_IO implies __GFP_WAIT
> (because IO cannot be done without potentially scheduling), so the code is
> not buggy, but the above 'yielding' of the CPU should be done in the
> GFP_BUFFER case as well. (which is __GFP_WAIT but not __GFP_IO)
> 
> Objections?

1) if __GFP_WAIT isn't set, we cannot run try_to_free_pages at all

2) you are right, we /can/ schedule when __GFP_IO isn't set, this is
   mistake ... now I'm getting confused about what __GFP_IO is all
   about, does anybody know the _exact_ meaning of __GFP_IO ?


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
