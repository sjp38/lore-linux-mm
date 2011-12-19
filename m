Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id E40BE6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 13:56:15 -0500 (EST)
Message-ID: <4EEF888C.4030101@ah.jp.nec.com>
Date: Mon, 19 Dec 2011 13:55:08 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20111219184047.GA5637@one.firstfloor.org>
In-Reply-To: <20111219184047.GA5637@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

Hi,

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
> This would keep ifdefery in the headers.

OK, I'll do it in the next post.
Thanks for the feedback.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
