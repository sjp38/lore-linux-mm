Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 13F656B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 08:02:04 -0400 (EDT)
Date: Mon, 17 Sep 2012 14:02:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v4] memcg: cleanup kmem tcp ifdefs
Message-ID: <20120917120200.GD27966@dhcp22.suse.cz>
References: <20120914112118.GG28039@dhcp22.suse.cz>
 <50531339.1000805@parallels.com>
 <20120914113400.GI28039@dhcp22.suse.cz>
 <50531696.1080708@parallels.com>
 <20120914120849.GL28039@dhcp22.suse.cz>
 <20120914124505.6d7756d1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120914124505.6d7756d1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

On Fri 14-09-12 12:45:05, Andrew Morton wrote:
> On Fri, 14 Sep 2012 14:08:49 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -50,8 +50,12 @@
> >  #include <linux/cpu.h>
> >  #include <linux/oom.h>
> >  #include "internal.h"
> > +
> > +#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
> >  #include <net/sock.h>
> > +#include <net/ip.h>
> >  #include <net/tcp_memcontrol.h>
> > +#endif
> 
> That wasn't a cleanup!
> 
> Why not just unconditionally include them?  That will impact compile
> time a teeny bit, but the code is cleaner.
> 
> And it's safer, too - conditionally including header files make it more
> likely that people will accidentally break the build by not testing all
> relevant CONFIG_foo combinations.

OK, fair point. Updated patch below:
---
