Date: Sun, 1 Sep 2002 20:28:20 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Time to do something about those loading times
Message-ID: <20020901202820.E781@nightmaster.csn.tu-chemnitz.de>
References: <1029399063.1641.65.camel@agnes.fremen.dune>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1029399063.1641.65.camel@agnes.fremen.dune>; from jfm2@club-internet.fr on Thu, Aug 15, 2002 at 10:11:02AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jean Francois Martinez <jfm2@club-internet.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jean,

On Thu, Aug 15, 2002 at 10:11:02AM +0200, Jean Francois Martinez wrote:
> Presently one of the things who are hindering Linux progress on the
> desktop is that the loading times are far higher than on Windows.  This
> gives the impression it is slow.
 
No they have different application design philosophies. A Unix
system is more than a kernel and the kernel tries best to support
the applications for Unix. Applications which are designed
another way are penalized for its poor design.

Thats called system design and application programmers should use
it properly instead of designing a Windows application and expect
it to run performant on Unix. It also doesn't work the other way
around[1].

So every Unix application that uses threads for everything, has no
useful commandline parameters, doesn't evaluate $HOME/.theconfig,
isn't startable remotely, modifies anything besides things I have
access to as a normal user, or is monolithic and uses lots of
shared libraries simply is a bad designed Unix application.

But thats just me(?).

Its better to penalize bad design and encourage good design by
slowing down bad behavior and making good behavior faster. Hope
that will never change.

Your slow loading problem can be solved by prelinking. Build a
linker to do this and save your favorite applications prelinked
(or build them simply completely statically linked). For windows
like applications ELF and ld-so are simply not designed.


Regards

Ingo Oeser

[1] Try redirecting output from your favorite windows
   application. Try embedding vim or emacs in it. Try to disable
   the GUI and control it via commandline parameters. See, thats
   by design.
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
