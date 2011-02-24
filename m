Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 19F358D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 04:35:22 -0500 (EST)
Date: Thu, 24 Feb 2011 10:35:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM
Message-ID: <20110224093519.GB20922@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
 <1298485162.7236.4.camel@nimitz>
 <20110224085227.1a3e185b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110224085227.1a3e185b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 24-02-11 08:52:27, KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Feb 2011 10:19:22 -0800
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > On Wed, 2011-02-23 at 16:10 +0100, Michal Hocko wrote:
> > > We can reduce this internal fragmentation by splitting the single
> > > page_cgroup array into more arrays where each one is well kmalloc
> > > aligned. This patch implements this idea. 
> > 
> > How about using alloc_pages_exact()?  These things aren't allocated
> > often enough to really get most of the benefits of being in a slab.
> > That'll at least get you down to a maximum of about PAGE_SIZE wasted.  
> > 
> 
> yes, alloc_pages_exact() is much better.
> 
> packing page_cgroups for multiple sections causes breakage in memory hotplug logic.

I am not sure I understand this. What do you mean by packing
page_cgroups for multiple sections? The patch I have posted doesn't do
any packing. Or do you mean that using a double array can break hotplog?
Not that this would change anything, alloc_pages_exact is really a
better solution, I am just curious ;) 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
