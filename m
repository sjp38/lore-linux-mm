Date: Mon, 2 Oct 2000 12:45:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] fix for VM  test9-pre7
In-Reply-To: <39D844E0.A8B4203E@norran.net>
Message-ID: <Pine.LNX.4.21.0010021244350.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Roger Larsson wrote:

> > The attached patch seems to fix all the reported deadlock
> > problems with the new VM. Basically they could be grouped
> > into 2 categories:
> > 
> > 1) __GFP_IO related locking issues
> > 2) something sleeps on a free/clean/inactive page goal
> >    that isn't worked towards
> 
> Trying mmapp002 it gets killed due to no free
> memory left...

????

I don't believe you. If the system runs out of memory the
current code should loop around and hang the system in a
nasty kind of livelock...

What error messages did you get?

> This was on a 96MB RAM, 180MHz PPro, IDE disks
> 
> Riel, have you tested to run with little memory or
>       limit your memory size? Or rather what system do
>       you test in.

I'm testing on a 64MB test machine, but haven't tested
this one with mem=8m yet..

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
