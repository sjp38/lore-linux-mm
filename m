Received: by ug-out-1314.google.com with SMTP id s2so358679uge
        for <linux-mm@kvack.org>; Thu, 17 May 2007 17:30:02 -0700 (PDT)
Message-ID: <29495f1d0705171730h552f7d80hc3f991f8dce9d4c2@mail.gmail.com>
Date: Thu, 17 May 2007 17:30:02 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH/RFC] Fix hugetlb pool allocation with empty nodes - V4
In-Reply-To: <1179353841.5867.53.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
	 <29495f1d0705161259p70a1e499tb831889fd2bcebcb@mail.gmail.com>
	 <1179353841.5867.53.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, andyw@uk.ibm.com
List-ID: <linux-mm.kvack.org>

On 5/16/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Wed, 2007-05-16 at 12:59 -0700, Nish Aravamudan wrote:
>
> <snip>
> >
> > This completely breaks hugepage allocation on 4-node x86_64 box I have
> > here. Each node has <4GB of memory, so all memory is ZONE_DMA and
> > ZONE_DMA32. gfp_zone(GFP_HIGHUSER) is ZONE_NORMAL, though. So all
> > nodes are not populated by the default initialization to an empty
> > nodemask.
> >
> > Thanks to Andy Whitcroft for helping me debug this.
> >
> > I'm not sure how to fix this -- but I ran into while trying to base my
> > sysfs hugepage allocation patches on top of yours.
>
> OK.  Try this.  Tested OK on 4 node [+ 1 pseudo node] ia64 and 2 node
> x86_64.  The x86_64 had 2G per node--all DMA32.
>
> Notes:
>
> 1) applies on 2.6.22-rc1-mm1 atop my earlier patch to add the call to
> check_highest_zone() to build_zonelists_in_zone_order().  I think it'll
> apply [with offsets] w/o that patch.

Could you give both patches (or just this one) against 2.6.22-rc1 or
current -linus? -mm1 has build issues on ppc64 and i386 (as reported
by Andy and Mel in other threads).

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
