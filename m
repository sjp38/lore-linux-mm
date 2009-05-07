Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5814D6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 22:20:30 -0400 (EDT)
Date: Thu, 7 May 2009 10:20:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/7] proc: export more page flags in /proc/kpageflags
Message-ID: <20090507022033.GC12281@localhost>
References: <20090507110431.b6a10746.minchan.kim@barrios-desktop> <20090507020736.GB12281@localhost> <20090507110843.2663.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507110843.2663.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 10:09:43AM +0800, KOSAKI Motohiro wrote:
> > On Thu, May 07, 2009 at 10:04:31AM +0800, Minchan Kim wrote:
> > > 
> > > Hi, 
> > > 
> > > > +#ifdef CONFIG_MEMORY_FAILURE
> > > > +	u |= kpf_copy_bit(k, KPF_HWPOISON,	PG_hwpoison);
> > > > +#endif
> > > 
> > > Did mmtom merge memory failure feature?
> > 
> > Maybe not yet.. but the #ifdef makes it safe :-)
> 
> Please don't do that.
> dependency of the out of tree code mean "please don't merge me".

OK. I'll keep that in mind for the next take.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
