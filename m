Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Tue, 7 May 2002 21:37:57 +0200
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol>
In-Reply-To: <Pine.LNX.4.33.0205071625570.1579-100000@erol>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E175Ame-0000Tb-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Smith <csmith@micromuse.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 20:37, Christian Smith wrote:
> I can clearly see this is flogging a dead horse, so I'll let it lie, save
> the following observations and comments inline:
> - The Linux VM is very difficult to pick up. Maybe not conceptually, but 
>   the implementation is a nightmare to follow. That's probably why it's so 
>   poorly documented.

It's poorly documented because the latest edition of Understanding the Linux
Kernel isn't out yet ;-)

Your best sources of documentation at this point are:

  - lxr.linux.no (or source navigator)
  - Andrea's slides
  - Understanding the Linux Kernel (mostly still applies)
  - background links on kernelnewbies.org

> - While rmap is the way to go, it's still more of a band-aid than an 
>   intergrated solution.

Nope, this would indicate you don't have a handled on the fundamental
algorithms.  Switching from virtual scanning to physical scanning is hardly
something you'd describe as a bandaid.

> - do_page_fault() is definately in the wrong place, or at least, the work 
>   it does (it finds the generic vma of the fault. This should be generic 
>   code.)

It's per-arch because different architectures have very different sets of
conditions that have to be handled.  If you like, you can try to break out
some cross-arch factors and make them into inlines or something.  That's
cleanup work that's hard and mostly thankless.  We need more gluttons for
punishment^W^W^W volunteers to tackle this kind of thing.

> - Most people appear to be aiming towards absolute speed in all cases, 
>   without considering the wider picture. Anything that makes choosing the 
>   correct page to page out will out do any level of code optimisation due 
>   to the obvious limits to IO speed. Looking at Linux VM performance 
>   against any of the BSDs and SysV should indicate that a split generic 
>   VM/pmap layer is easier to optimise for the heavy load conditions, not
>   to mention maintain.

The FreeBSD VM is maybe easy to optimise if you are Matt Dillon, but before
he came along it was a disaster.

The Linux VM is pretty much impossible to optimize for large memory machines
in its current form, that is why the move to switch from virtual scanning
to physical scanning.  Other than that, it's not too bad.

-- 
Daniel

(p.s., it's not really necessary to include the entire thread at the bottom
of each post.)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
