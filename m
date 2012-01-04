Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id CC85B6B004D
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 18:55:17 -0500 (EST)
Date: Wed, 4 Jan 2012 15:55:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] pagemap: export KPF_THP
Message-Id: <20120104155516.19535dc3.akpm@linux-foundation.org>
In-Reply-To: <1324506228-18327-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1324506228-18327-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed, 21 Dec 2011 17:23:47 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> This flag shows that a given pages is a subpage of transparent hugepage.
> It helps us debug and test kernel by showing physical address of thp.
>
> ...
>
> --- 3.2-rc5.orig/include/linux/kernel-page-flags.h
> +++ 3.2-rc5/include/linux/kernel-page-flags.h
> @@ -30,6 +30,7 @@
>  #define KPF_NOPAGE		20
>  
>  #define KPF_KSM			21
> +#define KPF_THP			22
>  

Please also update and test Documentation/vm/page-types.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
