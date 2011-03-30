Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A35768D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:54:04 -0400 (EDT)
Subject: Re: [PATCH]mmap: add alignment for some variables
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110329184110.0086924e.akpm@linux-foundation.org>
References: <1301277536.3981.27.camel@sli10-conroe>
	 <m2oc4v18x8.fsf@firstfloor.org>	<1301360054.3981.31.camel@sli10-conroe>
	 <20110329152434.d662706f.akpm@linux-foundation.org>
	 <1301446882.3981.33.camel@sli10-conroe>
	 <20110329180611.a71fe829.akpm@linux-foundation.org>
	 <1301447843.3981.48.camel@sli10-conroe>
	 <20110329182544.6ad4eccb.akpm@linux-foundation.org>
	 <1301449000.3981.52.camel@sli10-conroe>
	 <20110329184110.0086924e.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Mar 2011 09:54:01 +0800
Message-ID: <1301450041.3981.55.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 2011-03-30 at 09:41 +0800, Andrew Morton wrote:
> On Wed, 30 Mar 2011 09:36:40 +0800 Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > > how is it that this improves things?
> > Hmm, it actually is:
> > struct percpu_counter {
> >  	spinlock_t lock;
> >  	s64 count;
> >  #ifdef CONFIG_HOTPLUG_CPU
> >  	struct list_head list;	/* All percpu_counters are on a list */
> >  #endif
> >  	s32 __percpu *counters;
> >  } __attribute__((__aligned__(1 << (INTERNODE_CACHE_SHIFT))))
> > so lock and count are in one cache line.
> 
> ____cacheline_aligned_in_smp would achieve that?
____cacheline_aligned_in_smp can't guarantee the cache alignment for
multiple nodes, because the variable can be updated by multiple
nodes/cpus.

Thanks,
Shaohua


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
