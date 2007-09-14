Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070914085335.GA30407@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1189527657.5036.35.camel@localhost>
	 <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
	 <1189691837.5013.43.camel@localhost>
	 <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
	 <20070913182344.GB23752@skynet.ie>
	 <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
	 <20070913141704.4623ac57.akpm@linux-foundation.org>
	 <20070914085335.GA30407@skynet.ie>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 11:06:54 -0400
Message-Id: <1189782414.5315.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 09:53 +0100, Mel Gorman wrote:
> On (13/09/07 14:17), Andrew Morton didst pronounce:
> > On Thu, 13 Sep 2007 11:26:19 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > On Thu, 13 Sep 2007, Mel Gorman wrote:
> > > 
> > > > What do you see holding it up? Is it the fact we are no longer doing the
> > > > pointer packing and you don't want that structure to exist, or is it simply
> > > > a case that 2.6.23 is too close the door and it won't get adequate
> > > > coverage in -mm?
> > > 
> > > No its not the pointer packing. The problem is that the patches have not 
> > > been merged yet and 2.6.23 is close. We would need to merge it very soon 
> > > and get some exposure in mm. Andrew?
> > 
> > You rang?
> > 
> > To which patches do you refer?  "Memory Policy Cleanups and Enhancements"? 
> > That's still in my queue somewhere, but a) it has "RFC" in it which usually
> > makes me run away and b) we already have no fewer than 221 memory
> > management patches queued.
> > 
> 
> Christoph's question is in relation to the patchset "Use one zonelist per
> node instead of multiple zonelists v7" and whether one zonelist will be
> merged in 2.6.24 in your opinion. I am hoping "yes" because it removes that
> hack with ZONE_MOVABLE and policies. I had sent you a version (v5) but there
> were further suggestions on ways to improve it so we're up to v7 now. Lee
> will hopefully be able to determine if v7 regresses policy behaviour or not.
> 

Hi, Mel:

I'm running with your patches now.  An earlier version--just received v7
end of day yesterday.  Will rebuild today.  I've been using the kernel
with your patches for general patch development and kernel building on
my ia64 numa platform.  Before I rebooted to test another kernel
[reclaim scalability/noreclaim patch set], your mail prompted me to try
a couple of memtoy migration scripts.  I managed to hang/panic the
system with a null pointer deref and a very interesting stack trace,
which I didn't capture [want to test w/ v7].  The trace included some
kprobes functions--which I'm not using--and a lot of tcp/network stack
routines.  I have no clue whether these are related to your patches.
The hang that I experienced before the panic could have been a local
site network glitch [happens, sometimes] that triggered a fault in the
network stack.

Again, I'll retest with the v7 patches today.  In the meantime, you
might want to grab memtoy from:
http://free.linux.hp.com/~lts/Tools/memtoy-latest.tar.gz
and try out the test scripts in the Xpm-tests/Mbind directory.  Note
that these scripts assume a 4-node numa system, but from the comments
you should be able to mod them for whatever numa system you have
available.  Building memtoy can also be a bit of a challenge, depending
on your environment--no autoconfig or such.  Check out the README for
instructions/caveats/...

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
