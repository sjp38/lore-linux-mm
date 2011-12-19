Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 0D0EF6B0068
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 14:05:24 -0500 (EST)
Date: Mon, 19 Dec 2011 20:05:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
Message-ID: <20111219190514.GN16411@redhat.com>
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20111219184047.GA5637@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111219184047.GA5637@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Dec 19, 2011 at 07:40:47PM +0100, Andi Kleen wrote:
> > diff --git 3.2-rc5.orig/fs/proc/page.c 3.2-rc5/fs/proc/page.c
> > index 6d8e6a9..d436fc6 100644
> > --- 3.2-rc5.orig/fs/proc/page.c
> > +++ 3.2-rc5/fs/proc/page.c
> > @@ -116,6 +116,11 @@ u64 stable_page_flags(struct page *page)
> >  	if (PageHuge(page))
> >  		u |= 1 << KPF_HUGE;
> >  
> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +	if (PageTransCompound(page))
> > +		u |= 1 << KPF_THP;
> > +#endif
> 
> It would be better to have PageTransCompound be a dummy (always 0) 
> for !CONFIG_TRANSPARENT_HUGEPAGE and KPF_THP always defined.

It's already the case, that's the whole point of using
PageTransCompound instead of PageCompound (the former defines to 0 is
the config option is disabled).

> This would keep ifdefery in the headers.

Yes the #ifdef can go already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
