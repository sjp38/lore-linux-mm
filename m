Date: Wed, 4 Jun 2008 03:04:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
Message-ID: <20080604010428.GB30863@wotan.suse.de>
References: <20080603095956.781009952@amd.local0.net> <20080603100939.967775671@amd.local0.net> <1212515282.8505.19.camel@nimitz.home.sr71.net> <20080603182413.GJ20824@one.firstfloor.org> <1212519555.8505.33.camel@nimitz.home.sr71.net> <20080603205752.GK20824@one.firstfloor.org> <1212528479.7567.28.camel@nimitz.home.sr71.net> <4845DC72.5080206@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4845DC72.5080206@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 04, 2008 at 02:06:10AM +0200, Andi Kleen wrote:
> 
> > Also, as I said, users doesn't really know what the OS or hardware will
> > support 
> 
> The normal Linux expectation is that these kinds of users will not
> use huge pages at all.  Or rather if everybody was supposed to use
> them then all the interfaces would need to be greatly improved and any
> kinds of boot parameters would be out and they would need to be
> 100% integrated with the standard VM.
> 
> Hugepages are strictly an harder-to-use optimization for specific people
> who love to tweak (e.g. database administrators or benchmarkers). From
> what I heard so far these people like to have more control, not less.

Hi,

Well I think you both raise some valid points. Especially with 1GB
hugepages I agree with Andi that they are quite limiting and you need
to specify them at boot anyway really.

However I'm really not the right person to arbitrate or decide on the
exact final way the user will interact with these things, because I've
honestly never used hugepages for a serious app, nor am I involved with
libhugetlbfs etc etc.

Dave raises a good point with smaller hugepages sizes. They are
potentially much more usable than even 16M pages in a long running
system, so it probably doesn't hurt to have them available.

So I won't oppose this being tinkered with once it is in -mm or upstream.
So long as we try to make changes carefully. For example, there should
be no reason why we can't subsequently have a patch to register all
huge page sizes on boot, or if it is really important somebody might
write a patch to return the 1GB pages to the buddy allocator etc.

I'm basically just trying to follow the path of least resistance ;) So
I'm hoping that nobody is too upset with the current set of patches,
and from there I am very happy for people to submit incremental patches
to the user apis..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
