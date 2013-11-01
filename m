Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id B3E566B0036
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 02:23:59 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so3852998pbc.16
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 23:23:59 -0700 (PDT)
Received: from psmtp.com ([74.125.245.155])
        by mx.google.com with SMTP id sd2si3781766pbb.199.2013.10.31.23.23.58
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 23:23:58 -0700 (PDT)
Date: Fri, 01 Nov 2013 02:23:44 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1383287024-o4iedqct-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1383169499-25144-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1383169499-25144-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Wed, Oct 30, 2013 at 05:44:49PM -0400, Naoya Horiguchi wrote:
...
> diff --git v3.12-rc7-mmots-2013-10-29-16-24.orig/mm/pagewalk.c v3.12-rc7-mmots-2013-10-29-16-24/mm/pagewalk.c
> index 2beeabf..af93846 100644
> --- v3.12-rc7-mmots-2013-10-29-16-24.orig/mm/pagewalk.c
> +++ v3.12-rc7-mmots-2013-10-29-16-24/mm/pagewalk.c
> @@ -3,29 +3,49 @@
>  #include <linux/sched.h>
>  #include <linux/hugetlb.h>
>  
> -static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> -			  struct mm_walk *walk)
> +static inline bool skip_check(mm_walk *walk)

Sorry, I missed 'struct' here.
It happened to be lost in my squashing patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
