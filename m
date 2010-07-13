Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD9BB6B02AC
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:35:50 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6DGYd2O012793
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:34:39 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6DGZe2j132126
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:35:40 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6DGZcUG006761
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:35:39 -0400
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100713154335.GB2815@barrios-desktop>
References: <20100712155348.GA2815@barrios-desktop>
	 <20100713093006.GB14504@cmpxchg.org>
	 <20100713154335.GB2815@barrios-desktop>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 13 Jul 2010 09:35:33 -0700
Message-ID: <1279038933.10995.9.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-07-14 at 00:43 +0900, Minchan Kim wrote:
> 3 is not a big deal than 2 about memory usage.
> If the system use memory space fully(MAX_PHYSMEM_BITS 31), it just consumes
> 1024(128 * 8) byte. So now I think best solution is 2. 
> 
> Russell. What do you think about it? 

I'm not Russell, but I'll tell you what I think. :)

Make the sections 16MB.  You suggestion to add the start/end pfns
_doubles_ the size of the structure, and its size overhead.  We have
systems with a pretty tremendous amount of memory with 16MB sections.

If you _really_ can't make the section size smaller, and the vast
majority of the sections are fully populated, you could hack something
in.  We could, for instance, have a global list that's mostly readonly
which tells you which sections need to be have their sizes closely
inspected.  That would work OK if, for instance, you only needed to
check a couple of memory sections in the system.  It'll start to suck if
you made the lists very long.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
