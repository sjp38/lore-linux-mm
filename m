Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8CDA8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:48:25 -0400 (EDT)
Date: Mon, 28 Mar 2011 11:48:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: update documentation to describe usage_in_bytes
Message-ID: <20110328094820.GC5693@tiehlicka.suse.cz>
References: <20110321102420.GB26047@tiehlicka.suse.cz>
 <20110322091014.27677ab3.kamezawa.hiroyu@jp.fujitsu.com>
 <20110322104723.fd81dddc.nishimura@mxp.nes.nec.co.jp>
 <20110322073150.GA12940@tiehlicka.suse.cz>
 <20110323092708.021d555d.nishimura@mxp.nes.nec.co.jp>
 <20110323133517.de33d624.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328085508.c236e929.nishimura@mxp.nes.nec.co.jp>
 <20110328132550.08be4389.nishimura@mxp.nes.nec.co.jp>
 <20110328074341.GA5693@tiehlicka.suse.cz>
 <20110328181127.b8a2a1c5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110328181127.b8a2a1c5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 28-03-11 18:11:27, KAMEZAWA Hiroyuki wrote:
> On Mon, 28 Mar 2011 09:43:42 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Mon 28-03-11 13:25:50, Daisuke Nishimura wrote:
> > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
[...]
> > > +5.5 usage_in_bytes
> > > +
> > > +As described in 2.1, memory cgroup uses res_counter for tracking and limiting
> > > +the memory usage. memory.usage_in_bytes shows the current res_counter usage for
> > > +memory, and DOESN'T show a actual usage of RSS and Cache. It is usually bigger
> > > +than the actual usage for a performance improvement reason. 
> > 
> > Isn't an explicit mention about caching charges better?
> > 
> 
> It's difficult to distinguish which is spec. and which is implemnation details...

Sure. At least commit log should contain the implementation details IMO,
though.

> 
> My one here ;)
> ==
> 5.5 usage_in_bytes
> 
> For efficiency, as other kernel components, memory cgroup uses some optimization to
> avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
> method and doesn't show 'exact' value of usage, it's an fuzz value for efficient
> access. (Of course, when necessary, it's synchronized.)
> In usual, the value (RSS+CACHE) in memory.stat shows more exact value. IOW,

- In usual, the value (RSS+CACHE) in memory.stat shows more exact value. IOW,
+ (RSS+CACHE) value from memory.stat shows more exact value and should be used
+ by userspace. IOW,

?

> usage_in_bytes is less exact than memory.stat. The error will be larger on the larger
> hardwares which have many cpus and tasks.
> ==
> 
> Hmm ?

Looks much better.

Thanks
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
