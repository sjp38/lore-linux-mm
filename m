Date: Wed, 10 Jul 2002 05:38:44 +0100
From: John Levon <movement@marcelothewonderpenguin.com>
Subject: Re: Enhanced profiling support (was Re: vm lock contention reduction)
Message-ID: <20020710043844.GA69117@compsoc.man.ac.uk>
References: <Pine.LNX.4.44.0207081039390.2921-100000@home.transmeta.com> <3D29DCBC.5ADB7BE8@opersys.com> <20020710022208.GA56823@compsoc.man.ac.uk> <3D2BB505.889304A8@opersys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D2BB505.889304A8@opersys.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Karim Yaghmour <karim@opersys.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, Richard Moore <richardj_moore@uk.ibm.com>, bob <bob@watson.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2002 at 12:16:05AM -0400, Karim Yaghmour wrote:
 
[snip]
 
> And the list goes on.
 
Sure, there are all sorts of things where some tracing can come in
useful. The question is whether it's really something the mainline
kernel should be doing, and if the gung-ho approach is nice or not.

> The fact that so many kernel subsystems already have their own tracing
> built-in (see other posting)
 
Your list was almost entirely composed of per-driver debug routines.
This is not the same thing as logging trap entry/exits, syscalls etc
etc, on any level, and I'm a bit perplexed that you're making such an
assocation.
 
> expect user-space developers to efficiently use the kernel if they
> have
> absolutely no idea about the dynamic interaction their processes have
> with the kernel and how this interaction is influenced by and
> influences
> the interaction with other processes?
 
This is clearly an exaggeration. And seeing as something like LTT
doesn't (and cannot) tell the "whole story" either, I could throw the
same argument directly back at you. The point is, there comes a point of
no return where usefulness gets outweighed by ugliness. For the very few
cases that such detailed information is really useful, the user can
usually install the needed special-case tools.
 
In contrast a profiling mechanism that improves on the poor lot that
currently exists (gprof, readprofile) has a truly general utility, and
can hopefully be done without too much ugliness.
 
The primary reason I want to see something like this is to kill the ugly
code I have to maintain.

> > The entry.S examine-the-registers approach is simple enough, but
> > it's
> > not much more tasteful than sys_call_table hackery IMHO
>
> I guess we won't agree on this. From my point of view it is much
> better
> to have the code directly within entry.S for all to see instead of
> having some external software play around with the syscall table in a
> way kernel users can't trace back to the kernel's own code.

Eh ? I didn't say sys_call_table hackery was better. I said the entry.S
thing wasn't much better ...

regards
john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
