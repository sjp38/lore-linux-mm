Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 36EC816B18
	for <linux-mm@kvack.org>; Sun, 18 Mar 2001 13:42:28 -0300 (EST)
Date: Sun, 18 Mar 2001 11:43:48 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: changing mm->mmap_sem  (was: Re: system call for process
 information?)
In-Reply-To: <Pine.LNX.4.33.0103181407520.1426-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0103181122480.13050-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Resent-To: sct@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.21.0103181250050.13050@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: sct@conectiva.com.br, linux-kernel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

On Sun, 18 Mar 2001, Mike Galbraith wrote:

> > No, this was make -j30 bzImage.  (nscd was running though...)
> 
> I rebooted, shut down nscd prior to testing and did 5 builds in a row
> without a single gripe.  Started nscd for sixth run and instantly the
> kernel griped.  Yup.. threaded apps pushing swap.

OK, I'll write some code to prevent multiple threads from
stepping all over each other when they pagefault at the
same address.

What would be the preferred method of fixing this ?

- fixing do_swap_page and all ->nopage functions
- hacking handle_mm_fault to make sure no overlapping
  pagefaults will be served at the same time

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
