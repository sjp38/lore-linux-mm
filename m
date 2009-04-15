Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 466605F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 09:54:07 -0400 (EDT)
Date: Wed, 15 Apr 2009 15:57:49 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
Message-ID: <20090415135749.GD14687@one.firstfloor.org>
References: <20090414133448.C645.A69D9226@jp.fujitsu.com> <20090414064132.GB5746@localhost> <20090414154606.C665.A69D9226@jp.fujitsu.com> <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090415131800.GA11191@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> That's pretty good separations. I guess it would be convenient to make the
> extra kernel flags available under CONFIG_DEBUG_KERNEL?

Yes.

BTW an alternative would be just someone implementing a suitable
command/macro in crash(1) and tell the kernel hackers to run that on
/proc/kcore. That would have the advantage to not require code.

> > > > > > - PG_compound
> > 
> > I would combine these three into a pseudo "large page" flag.
> 
> Very neat idea! Patch updated accordingly.
>  
> However - one pity I observed:
> 
> # ./page-areas 0x008000
>     offset      len         KB
>       3088        4       16KB
> 
> We can no longer tell if the above line means one 4-page hugepage, or two
> 2-page hugepages... Adding PG_COMPOUND_TAIL into the CONFIG_DEBUG_KERNEL block

There's only a single size (2 or 4MB), at worst two.

> > 
> > PG_poison is also useful to export. But since it depends on my
> > patchkit I will pull a patch for that into the HWPOISON series.
> 
> That's not a problem - since the PG_poison line is be protected by
> #ifdef CONFIG_MEMORY_FAILURE :-) 

Good point. I added a patch to only add it to my pile,
but I can drop that again.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
