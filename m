Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4C1956B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 22:09:39 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4729jZ4009143
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 7 May 2009 11:09:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9023445DE50
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:09:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64C4A45DD75
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:09:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 259D81DB803F
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:09:45 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC97C1DB803A
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:09:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] proc: export more page flags in /proc/kpageflags
In-Reply-To: <20090507020736.GB12281@localhost>
References: <20090507110431.b6a10746.minchan.kim@barrios-desktop> <20090507020736.GB12281@localhost>
Message-Id: <20090507110843.2663.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  7 May 2009 11:09:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu, May 07, 2009 at 10:04:31AM +0800, Minchan Kim wrote:
> > 
> > Hi, 
> > 
> > > +#ifdef CONFIG_MEMORY_FAILURE
> > > +	u |= kpf_copy_bit(k, KPF_HWPOISON,	PG_hwpoison);
> > > +#endif
> > 
> > Did mmtom merge memory failure feature?
> 
> Maybe not yet.. but the #ifdef makes it safe :-)

Please don't do that.
dependency of the out of tree code mean "please don't merge me".




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
