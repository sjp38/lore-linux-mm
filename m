Message-ID: <DD0DC14935B1D211981A00105A1B28DB018BE677@NL-ASD-EXCH-1>
From: "Leeuw van der, Tim" <tim.leeuwvander@nl.unisys.com>
Subject: RE: [prePATCH] new VM (2.4.0-test4)
Date: Thu, 17 Aug 2000 02:51:03 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Rik van Riel ' <riel@conectiva.com.br>, "'linux-kernel@vger.rutgers.edu'" <linux-kernel@vger.rutgers.edu>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

 
Hello!

I tried the new patch last night / this morning and so far, it's GREAT. It
ROCKS.

I can install .deb files with good interactive performance while compiling a
kernel. Gnome/Enlightenment startup has never been so fast, the difference
is clearly visible. It's great.

Much faster than the untuned version, and much faster than 2.2.17pre.


The only thing I haven't yet tried is playing back an MP3 while doing all
this. I'm more than happy with what I've seen so far :-)

And you say that it can get even faster? WoW!


Much success,

--Tim

-----Original Message-----
From: Rik van Riel
To: tim.leeuwvander@nl.unisys.com
Cc: linux-kernel@vger.rutgers.edu
Sent: 8/16/00 5:34 PM
Subject: Re: [prePATCH] new VM (2.4.0-test4)

On Wed, 16 Aug 2000, Tim N . van der Leeuw wrote:

> Performance is quite good, much better than plain 2.4testX for
> certain. Under load the performance starts to fall apart: On my
> 64Mb machine, MP3 playback and interactive performance sufer
> horribly when installing a package with dpkg.

You may want to test the second patch against 2.4.0-test7-pre4.
That patch has been tuned for performance, in contrast to the
patch you've been testing with ;)

> When the load is not so high, the computer is very very fast!
> I'm very encouraged by the results so far.

cheers,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
