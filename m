Date: Wed, 26 Apr 2000 16:23:53 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000426162353.O3792@redhat.com>
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com> <20000425120657.B7176@stormix.com> <20000426120130.E3792@redhat.com> <200004261125.EAA12302@pizda.ninka.net> <20000426140031.L3792@redhat.com> <200004261311.GAA13838@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200004261311.GAA13838@pizda.ninka.net>; from davem@redhat.com on Wed, Apr 26, 2000 at 06:11:15AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, sim@stormix.com, jgarzik@mandrakesoft.com, riel@nl.linux.org, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 26, 2000 at 06:11:15AM -0700, David S. Miller wrote:
> 
>    Doing it isn't the problem.  Doing it efficiently is, if you have 
>    fork() and mremap() in the picture.  With mremap(), you cannot assume
>    that the virtual address of an anonymous page is the same in all
>    processes which have the page mapped.
> 
> Who makes that assumption?

Nobody does --- that's the point.  If you _could_ make that assumption,
then looking up the vma which maps a given page in a given mm would be
easy.  But because the assumption doesn't hold, you have to walk all of
the vmas.

> In my implementation there is no linear scan, only VMA's which
> can actually contain the anonymous page in question are scanned.
> 
> It's called an anonymous layer, and it provides pseudo backing objects
> for VMA's which have at least one privatized anonymous page.
...

> Instead of talk, I'll show some code :-)  The following is the
> anon layer I implemented for 2.3.x in my hacks.

OK --- I'm assuming you allow all of these address spaces to act as 
swapper address spaces for the purpose of the swap cache?  This looks
good, do you have the rest of the VM changes in a usable (testable)
state?

On fork(), I assume you just leave multiple vmas attached to the same
address space?  With things like mprotect, you'll still have a list
of vmas to search for in this design, I'd think.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
