Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 9ED0916B1B
	for <linux-mm@kvack.org>; Mon, 26 Mar 2001 13:18:40 -0300 (EST)
Date: Mon, 26 Mar 2001 13:00:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: memory mgmt/tuning for diskless machines
In-Reply-To: <3ABF501D.CB800A16@linuxjedi.org>
Message-ID: <Pine.LNX.4.21.0103261258270.1863-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David L. Parsley" <parsley@linuxjedi.org>
Cc: linux-mm@kvack.org, Jonathan Morton <chromi@cyberspace.org>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Mar 2001, David L. Parsley wrote:

> I'm working on a project for building diskless multimedia terminals/game
> consoles.  One issue I'm having is my terminal seems to go OOM and crash
> from time to time.  It's strange, I would expect the OOM killer to blow
> away X, but it doesn't - the machine just becomes unresponsive.
> 
> Since this is a quasi-embedded platform, what I'd REALLY like to do is
> tune the vm so mallocs fail when freepages falls below a certain point. 

Hi David,

I think you might want to talk with Jonathan Morton about
your situation. Jonathan is working on a non-overcommit
patch which will make sure no more memory is malloc()ed
than what is available.

Chances are this patch will stay separate for the kernel
for some more time and get integrated later when it is
well-tested and there is a certain userbase who really
want/need the patch (I suspect both of these will happen
rather soon, though;)).

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
