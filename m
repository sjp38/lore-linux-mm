Date: Tue, 26 Jun 2001 02:07:44 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [RFC] VM statistics to gather
In-Reply-To: <3B380E7B.6609337F@uow.edu.au>
Message-ID: <Pine.LNX.4.21.0106260206240.1676-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 26 Jun 2001, Andrew Morton wrote:

> Rik van Riel wrote:
> > 
> > Hi,
> > 
> > I am starting the process of adding more detailed instrumentation
> > to the VM subsystem and am wondering which statistics to add.
> > A quick start of things to measure are below, but I've probably
> > missed some things. Comments are welcome ...
> 
> Neat.
> 
> - bdflush wakeups
> - pages written via page_launder's writepage by kswapd
> - pages written via page_launder's writepage by non-PF_MEMALLOC
>   tasks.  (ext3 has an interest in this because of nasty cross-fs
>   reentrancy and journal overflow problems with writepage)

Does ext3 call page_launder() with __GFP_IO ? 

If it does not (which I believe so), page_launder() without PF_MEMALLOC
never happens. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
