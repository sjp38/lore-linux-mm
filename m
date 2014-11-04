Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7D97C6B0075
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 10:00:42 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id gq15so1049198lab.1
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 07:00:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si1201870lbw.43.2014.11.04.07.00.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 07:00:40 -0800 (PST)
Date: Tue, 4 Nov 2014 16:00:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
Message-ID: <20141104150039.GF22207@dhcp22.suse.cz>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
 <54589017.9060604@jp.fujitsu.com>
 <20141104132701.GA18441@phnom.home.cmpxchg.org>
 <20141104134110.GD22207@dhcp22.suse.cz>
 <20141104140937.GA18602@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141104140937.GA18602@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 04-11-14 09:09:37, Johannes Weiner wrote:
> On Tue, Nov 04, 2014 at 02:41:10PM +0100, Michal Hocko wrote:
> > On Tue 04-11-14 08:27:01, Johannes Weiner wrote:
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Subject: [patch] mm: move page->mem_cgroup bad page handling into generic code fix
> > > 
> > > Remove obsolete memory saving recommendations from the MEMCG Kconfig
> > > help text.
> > 
> > The memory overhead is still there. So I do not think it is good to
> > remove the message altogether. The current overhead might be 4 or 8B
> > depending on the configuration. What about
> > "
> > 	Note that setting this option might increase fixed memory
> > 	overhead associated with each page descriptor in the system.
> > 	The memory overhead depends on the architecture and other
> > 	configuration options which have influence on the size and
> > 	alignment on the page descriptor (struct page). Namely
> > 	CONFIG_SLUB has a requirement for page alignment to two words
> > 	which in turn means that 64b systems might not see any memory
> > 	overhead as the additional data fits into alignment. On the
> > 	other hand 32b systems might see 8B memory overhead.
> > "
> 
> What difference does it make whether this feature maybe costs an extra
> pointer per page or not?  These texts are supposed to help decide with
> the selection, but this is not a "good to have, if affordable" type of
> runtime debugging option.  You either need cgroup memory accounting
> and limiting or not.  There is no possible trade-off to be had.

If you are compiling the kernel for your specific usecase then it
is clear. You enable only what you really need/want. But if you are
providing a pre-built kernel and considering which features to enable
then an information about overhead might be useful. You can simply
disable the feature for memory restricted kernel flavors.

> Slub and numa balancing don't mention this, either, simply because
> this cost is negligible or irrelevant when it comes to these knobs.

I agree that the overhead seems negligible but does it hurt us to
mention it though?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
