Date: Fri, 27 Oct 2000 19:10:10 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Discussion on my OOM killer API
Message-ID: <20001027191010.N18138@nightmaster.csn.tu-chemnitz.de>
References: <Pine.LNX.4.21.0010261857580.15696-100000@duckman.distro.conectiva> <Pine.LNX.4.10.10010270056590.11273-100000@dax.joh.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010270056590.11273-100000@dax.joh.cam.ac.uk>; from jas88@cam.ac.uk on Fri, Oct 27, 2000 at 12:58:44AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Sutherland <jas88@cam.ac.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 27, 2000 at 12:58:44AM +0100, James Sutherland wrote:
> Which begs the question, where did the userspace OOM policy daemon go? It,
> coupled with Rik's simple in-kernel last-ditch handler, should cover most
> eventualities without the need for nasty kernel kludges.

If I do the full blown variant of my patch: 

echo "my-kewl-oom-killer" >/proc/sys/vm/oom_handler

will try to load the module with this name for a new one and
uninstall the old one.

The original idea was an simple "I install a module and lock it
into memory" approach[1] for kernel hackers, which is _really_
easy to to and flexibility for nothing[2].

If the Rik and Linus prefer the user-accessable variant via
/proc, I'll happily implement this.

I just intended to solve a "religious" discussion via code
instead of words ;-)

Regards

Ingo Oeser

[1] http://www.tu-chemnitz.de/~ioe/oom_kill_api.patch
[2] That's why I called it "simpliest API ever" ;-)
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
