Message-ID: <3ABF6EA0.A2454B66@linuxjedi.org>
Date: Mon, 26 Mar 2001 11:30:24 -0500
From: "David L. Parsley" <parsley@linuxjedi.org>
MIME-Version: 1.0
Subject: Re: memory mgmt/tuning for diskless machines
References: <Pine.LNX.4.21.0103261258270.1863-100000@imladris.rielhome.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Jonathan Morton <chromi@cyberspace.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Mon, 26 Mar 2001, David L. Parsley wrote:
> 
> > I'm working on a project for building diskless multimedia terminals/game
> > consoles.  One issue I'm having is my terminal seems to go OOM and crash
> > from time to time.  It's strange, I would expect the OOM killer to blow
> > away X, but it doesn't - the machine just becomes unresponsive.
> >
> > Since this is a quasi-embedded platform, what I'd REALLY like to do is
> > tune the vm so mallocs fail when freepages falls below a certain point.
> 
> Hi David,
> 
> I think you might want to talk with Jonathan Morton about
> your situation. Jonathan is working on a non-overcommit
> patch which will make sure no more memory is malloc()ed
> than what is available.

Thanks Rick, I'll bet you're right.  I changed the sysctl registration
to make /proc/sys/vm/freepages read-write, and even playing with it for
a while it was a no-win.  Either 1) the machine would become
unresponsive, or 2) X would crash.  For embedded systems, the
non-over-commit patch is almost certainly the way to go - and we all
know how popular embedded Linux is these days. ;-)

I'll try to search for his patch in kernel archives and let you know how
it works out.

Jonathan - if you could ship me the patch I'd appreciate it, but I'll
try searching first.

regards,
	David

-- 
David L. Parsley
Network Administrator
Roanoke College
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
