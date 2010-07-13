Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BE60E6B02A9
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:44:35 -0400 (EDT)
Received: by pwi8 with SMTP id 8so2732965pwi.14
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 09:44:34 -0700 (PDT)
Date: Wed, 14 Jul 2010 01:44:23 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-ID: <20100713164423.GC2815@barrios-desktop>
References: <20100712155348.GA2815@barrios-desktop>
 <20100713093006.GB14504@cmpxchg.org>
 <20100713154335.GB2815@barrios-desktop>
 <1279038933.10995.9.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279038933.10995.9.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Dave. 

On Tue, Jul 13, 2010 at 09:35:33AM -0700, Dave Hansen wrote:
> On Wed, 2010-07-14 at 00:43 +0900, Minchan Kim wrote:
> > 3 is not a big deal than 2 about memory usage.
> > If the system use memory space fully(MAX_PHYSMEM_BITS 31), it just consumes
> > 1024(128 * 8) byte. So now I think best solution is 2. 
> > 
> > Russell. What do you think about it? 
> 
> I'm not Russell, but I'll tell you what I think. :)
> 

No problem. :)

> Make the sections 16MB.  You suggestion to add the start/end pfns

I hope so. 

> _doubles_ the size of the structure, and its size overhead.  We have
> systems with a pretty tremendous amount of memory with 16MB sections.

Yes. it does in several GB server system.

> 
> If you _really_ can't make the section size smaller, and the vast
> majority of the sections are fully populated, you could hack something
> in.  We could, for instance, have a global list that's mostly readonly
> which tells you which sections need to be have their sizes closely
> inspected.  That would work OK if, for instance, you only needed to
> check a couple of memory sections in the system.  It'll start to suck if
> you made the lists very long.

Thanks for advise. As I say, I hope Russell accept 16M section. 

> 
> -- Dave
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
