Date: Wed, 30 Jul 2008 10:35:52 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: sparcemem or discontig?
Message-ID: <20080730093552.GD1369@brain>
References: <488F5D5F.9010006@sciatl.com> <1217368281.13228.72.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1217368281.13228.72.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: C Michael Sundius <Michael.sundius@sciatl.com>, linux-mm@kvack.org, msundius@sundius.com
List-ID: <linux-mm.kvack.org>

On Tue, Jul 29, 2008 at 02:51:21PM -0700, Dave Hansen wrote:
> On Tue, 2008-07-29 at 11:11 -0700, C Michael Sundius wrote:
> > 
> > My understanding is that SPARCEMEM is the way of the future, and since
> > I don't really have a NUMA machine, maybe sparcemem is more appropriate,
> > yes? On the other hand I can't find much info about how it works or how
> > to add support for it on an architecture that has here-to-fore not
> > supported that option.
> > 
> > Is there anywhere that there is a paper or rfp that describes how the
> > spacemem (or discontig) features work (and/or the differences between
> > then)?
> 
> I think you're talking about sparsemem. :)
> 
> My opinion is that NUMA and DISCONTIG are too intertwined to be useful
> apart from the other.  I use sparsemem on my non-NUMA 2 CPU laptop since
> it has a 1GB hole.  It is *possible* to use DISCONTIG without NUMA, and
> I'm sure people use it this way, but I just personally think it is a bit
> of a pain.  
> 
> Basically, to add sparsemem support for an architecture, you need a
> header like these:
> 
> dave@nimitz:~/lse/linux/2.5/linux-2.6.git$ find | grep sparse | xargs
> grep -c '^.*$'
> ./include/asm-powerpc/sparsemem.h:32
> ./include/asm-x86/sparsemem.h:34
> ./include/asm-sh/sparsemem.h:16
> ./include/asm-mips/sparsemem.h:14
> ./include/asm-ia64/sparsemem.h:20
> ./include/asm-s390/sparsemem.h:18
> ./include/asm-arm/sparsemem.h:10
> 
> These are generally pretty darn small (the largest is 34 lines).  You
> also need to tweak some things in your per-arch Kconfig.  ARM looks like
> a pretty simple use of sparsemem.  You might want to start with what
> they've done.  We tried really, really hard to make it easy to add to
> new architectures.
> 
> Feel free to cc me and Andy (cc'd) on the patches that you come up with.
> I'd be happy to sanity check them for you.  If *you* want to document
> the process for the next guy, I'm sure we'd be able to find some spot in
> Documentation/ so the next guy has an easier time. :)

Always interested in new users of sparsemem.  Cc me :).

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
