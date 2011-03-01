Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BEFBA8D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 21:21:53 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2121qTv011478
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 21:01:52 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C766D6E8036
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 21:21:51 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p212LpEF378504
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 21:21:51 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p212Lpr2003992
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 21:21:51 -0500
Subject: Re: [PATCH] ksm: add vm_stat and meminfo entry to reflect pte
 mapping to ksm pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <201102262256.31565.nai.xia@gmail.com>
References: <201102262256.31565.nai.xia@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 28 Feb 2011 18:21:48 -0800
Message-ID: <1298946108.9138.1173.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Sat, 2011-02-26 at 22:56 +0800, Nai Xia wrote
> @@ -904,6 +905,10 @@ static int try_to_merge_one_page(struct vm_area_struct 
> *vma,
>                          */
>                         set_page_stable_node(page, NULL);
>                         mark_page_accessed(page);
> +                       if (mapcount)
> +                               add_zone_page_state(page_zone(page),
> +                                                   NR_KSM_PAGES_SHARING,
> +                                                   mapcount);
>                         err = 0;
>                 } else if (pages_identical(page, kpage))
>                         err = replace_page(vma, page, kpage, orig_pte); 

If you're going to store this per-zone, does it make sense to have it
show up in /proc/zoneinfo?  meminfo's also getting pretty porky these
days, so I almost wonder if it should stay in zoneinfo only.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
