Date: Sat, 26 Apr 2003 09:11:59 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: maximum possible memory limit ..
Message-ID: <20030426091158.O626@nightmaster.csn.tu-chemnitz.de>
References: <20030424200524.5030a86b.bain@tcsn.co.za> <200304241835.h3OIZxvj006418@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200304241835.h3OIZxvj006418@turing-police.cc.vt.edu>; from Valdis.Kletnieks@vt.edu on Thu, Apr 24, 2003 at 02:35:59PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Henti Smith <bain@tcsn.co.za>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Apr 24, 2003 at 02:35:59PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 24 Apr 2003 20:05:24 +0200, Henti Smith <bain@tcsn.co.za>  said:
> > I had a discussion with somebody watching the whole M$ server launch and
> > mentioned then new systems supports up to a terabyte of ram. 

> Well.. sure.. it's easy enough to write something that supports plugging in
> a terabyte.  The *tricky* part is supporting it well - you have page table
> issues, you have swapping/thrashing issues (if you *do* have to page something
> out, you're in trouble.. ;), you have process scheduling issues (how many
> Apache processes does it take to use up a terabyte?  What's your load average
> at that point?), you have multi-processor scaling issues (you're gonna want
> to have 64+ processors, etc..)

This is all a kind of DSW[1]. Consider the ordinal limits of the
data structures used to represent memory and cpus.

Since Linux uses bitmaps to represent CPUs, we can support as
much CPUs, as much of such bitmaps (there are many of them) into
memory.

numphyspages is unsigned long. That means on 64-Bit platforms you
can support up to 2^(64+PAGE_SHIFT)-1 bytes of memory.

So I think, we've won this time, but the mm-people might know even
more limiting factors to show the real theoretical limits.

> Consider - the number of machines with over a terabyte of RAM is limited:
> 
> http://www.llnl.gov/asci/platforms/platforms.html
> 
> That's the sort of box that has a terabyte.  Do you *really* think that
> M$ 2003 has all the stuff needed to scale to THAT size?

The nice thing about DSWs is, that sanity doesn't matter ;-)
And yes, this is important, as people continue to buy useless and
oversized things to compensate for something.

PS: CC'ed to linux-mm instead of linux-kernel.

Regards

Ingo Oeser
[1] Dick Size War
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
