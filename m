Date: Mon, 4 Sep 2000 12:34:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: zero copy IO project
In-Reply-To: <39B3A5F8.29C18EC1@free.fr>
Message-ID: <Pine.LNX.4.21.0009041231430.8855-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fabio Riccardi <fabio.riccardi@free.fr>
Cc: linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Sep 2000, Fabio Riccardi wrote:

> after having analyzed a bit the various souces of inefficiency
> in Linux (wrt a high end server), and having discarded what
> other people already seem to be working on, I'd like to enroll
> myself into a zero copy IO project, much like that of UVM,
> genie, io-lite, fbufs, etc.
> 
> Is anybody aready working on this? Does anybody have ideas about
> it? Anybody interested in a discussion of pros and cons of such
> an architectural change to Linux?

The project (and data structure used) is called KIOBUF.

IIRC Stephen Tweedie and Ben LaHaise are working on it
and it will be a more generic zero-copy IO infrastructure
than io-lite and others.

Ben LaHaise made some documentation (or at least, some
slides) on KIOBUFs for the Ottawa Linux Symposium. You may
be able to get some documentation from him, and you can go
to the OLS ftp site to download an mp3 of the VM lecture...

Also, I'm sure they must have some TODO items for you ;))
(if you're interested in helping out)

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
