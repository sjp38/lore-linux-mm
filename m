Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 6343016BC2
	for <linux-mm@kvack.org>; Fri, 23 Mar 2001 11:57:53 -0300 (EST)
Date: Fri, 23 Mar 2001 11:56:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <3ABB2A19.D82B50A7@evision-ventures.com>
Message-ID: <Pine.LNX.4.21.0103231154440.29682-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Dalecki <dalecki@evision-ventures.com>
Cc: Stephen Clouse <stephenc@theiqgroup.com>, Guest section DW <dwguest@win.tue.nl>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2001, Martin Dalecki wrote:
> Rik van Riel wrote:
> > On Sat, 23 Mar 2002, Martin Dalecki wrote:
> > 
> > > This is due to the broken calculation formula in oom_kill().
> > 
> > Feel free to write better-working code.
> 
> I don't get paid for it and I'm not idling through my days...

  <similar response from Andries>

Well, in that case you'll have to live with the current OOM
killer.  Martin wrote down a pretty detailed description of
what's wrong with my algorithm, if it really bothers him he
should be able to come up with something better.

Personally, I think there is more important VM code to look
after, since OOM is a pretty rare occurrance anyway.

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
