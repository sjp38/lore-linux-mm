Date: Mon, 2 Apr 2001 22:04:24 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: memory mgmt/tuning for diskless machines
In-Reply-To: <3ABF501D.CB800A16@linuxjedi.org>
Message-ID: <Pine.LNX.4.21.0104022159430.6947-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David L. Parsley" <parsley@linuxjedi.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 26 Mar 2001, David L. Parsley wrote:

> Hi,
> 
> I'm working on a project for building diskless multimedia terminals/game
> consoles.  One issue I'm having is my terminal seems to go OOM and crash
> from time to time.  It's strange, I would expect the OOM killer to blow
> away X, but it doesn't - the machine just becomes unresponsive.
> 
> Since this is a quasi-embedded platform, what I'd REALLY like to do is
> tune the vm so mallocs fail when freepages falls below a certain point. 
> I'm using cramfs, and what I suspect is happening is that once memory
> gets too low, the kernel doesn't have enough memory to uncompress
> pages.  Since there's no swap, there's nothing to page out.
> 
> So... it occured to me I could tune this with /proc/sys/vm/freepages -
> but now I find that it's read-only, and I can't echo x y z > freepages
> like I used to.  What's up with that?

It should work. Are you sure you're trying to change it as root ? 

> Suggestions?

Which kernel version are you using ? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
