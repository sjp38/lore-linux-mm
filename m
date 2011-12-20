Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B54116B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 22:45:41 -0500 (EST)
Date: Tue, 20 Dec 2011 11:35:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
Message-ID: <20111220033537.GA14270@localhost>
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Dec 20, 2011 at 02:38:38AM +0800, Naoya Horiguchi wrote:
> This flag shows that a given pages is a subpage of transparent hugepage.
> It does not care about whether it is a head page or a tail page, because
> it's clear from pfn of the target page which you should know when you read
> /proc/kpageflags.

OK, this is aligning with KPF_HUGE. For those who only care about
head/tail pages, will the KPF_COMPOUND_HEAD/KPF_COMPOUND_TAIL flags be
set automatically for thp? Which may be more convenient to test/filter
than the page address.

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

As you already discussed, the below #ifdef should be removed.
In fact, kernel-page-flags.h is intended for direct inclusion by
user space tools, so must not have any conditional defines.

> --- 3.2-rc5.orig/include/linux/kernel-page-flags.h
> +++ 3.2-rc5/include/linux/kernel-page-flags.h
> @@ -31,6 +31,10 @@
>  
>  #define KPF_KSM			21
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#define KPF_THP			22
> +#endif
> +
>  /* kernel hacking assistances
>   * WARNING: subject to change, never rely on them!
>   */
> -- 
> 1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
