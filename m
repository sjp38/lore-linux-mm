From: Rob Landley <rob@landley.net>
Reply-To: rob@landley.net
Subject: Re: Process in D state (was Re: 2.6.0-test5-mm2)
Date: Sun, 21 Sep 2003 14:30:50 -0400
References: <20030914234843.20cea5b3.akpm@osdl.org> <200309201534.36362.rob@landley.net> <20030920144902.47c2c7c4.akpm@osdl.org>
In-Reply-To: <20030920144902.47c2c7c4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200309211430.51367.rob@landley.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 20 September 2003 17:49, Andrew Morton wrote:
> Rob Landley <rob@landley.net> wrote:
> > But, twice in a row now I've made this happen:
> >
> >   1391 pts/1    S      0:00 /bin/bash
> >   1419 pts/1    S      0:00 /bin/sh ./build.sh
> >   1423 pts/1    S      0:00 /bin/bash
> >  /home/landley/pending/newfirmware/make-stat
> >   1447 pts/1    D      0:04 tar xvjf
> >  /home/landley/pending/newfirmware/base/linux
> >   1448 pts/1    S      0:37 bzip2 -d
> >
> >  All I have to do is run my script, it tries to extract the kernel
> > tarball, and tar hangs in D state.
> >
> >  How do I debug this?  (Is there some way to get the output of Ctrl-ScrLk
> > to go to the log instead of just the console?  My system isn't currently
> > hung, it's just got a process that is.  This process being hung prevents
> > my partitions from being unmounted on shutdown, which is annoying.)
>
> sysrq-T followed by `dmesg -s 1000000 > foo' should capture it.

I'll give it a try...

Okay, I reproduced the hang.  Now...  It's beeping at me?

It helps to have magic sysrq selected in menuconfig.  I'll get back to this...

> >  Other miscelanous bugs: cut and paste only works some of the time (it
> > pastes blanks other times, dunno if this was -test5 or -mm2; it worked
> > fine in -test4).
>
> vgacon? fbcon? X11?

X11.  At first I thought it was only between certain apps, but now I thin it's 
just plain intermittent.  Smells like a race or uninitialized variable or 
something.  (For all I know, the bug could be in kde, although I'm using 
RH9's binaries.  I've seen it cutting and pasting between kmail, konsole, and 
konqueror.  Sorry, can't reproduce this one at will...

> >  The key repeat problem is still there, although still highly
> > intermittent.
>
> I think Andries says that some keyboards just forget to send up codes.
> We'll probably need some kernel boot parameter to support these, using the
> keyboard's silly native autorepeat.

I'd rather not have any autorepeat at all than have it go intermittently nuts 
on me...

> >  The boot hung enabling swap space once.  I don't know why.  (Init was
> > already running and everything...)
>
> Probably the O_DIRECT locking bug: I had `rpmv' getting stuck on boot for a
> while.  mm3 fixed that.

I'll upgrade after I get you your sysrq-t.

Rob
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
