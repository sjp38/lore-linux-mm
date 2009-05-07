Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 858336B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 22:07:54 -0400 (EDT)
Date: Thu, 7 May 2009 10:07:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/7] proc: export more page flags in /proc/kpageflags
Message-ID: <20090507020736.GB12281@localhost>
References: <20090507012116.996644836@intel.com> <20090507014914.364045992@intel.com> <20090507110431.b6a10746.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507110431.b6a10746.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 10:04:31AM +0800, Minchan Kim wrote:
> 
> Hi, 
> 
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +	u |= kpf_copy_bit(k, KPF_HWPOISON,	PG_hwpoison);
> > +#endif
> 
> Did mmtom merge memory failure feature?

Maybe not yet.. but the #ifdef makes it safe :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
