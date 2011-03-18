Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7EFA88D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 02:44:43 -0400 (EDT)
From: "xianai@nju.edu.cn" <xianai@nju.edu.cn>
Reply-To: xianai@nju.edu.cn
Subject: Re: [PATCH] ksm: add vm_stat and meminfo entry to reflect pte mapping to ksm pages
Date: Fri, 18 Mar 2011 14:44:27 +0800
References: <201102262256.31565.nai.xia@gmail.com> <1298946108.9138.1173.camel@nimitz>
In-Reply-To: <1298946108.9138.1173.camel@nimitz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201103181444.27725.xianai@nju.edu.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>


>On Tuesday 01 March 2011, at 10:21:48, <Dave Hansen <dave@linux.vnet.ibm.com>> wrote
> On Sat, 2011-02-26 at 22:56 +0800, Nai Xia wrote
> > @@ -904,6 +905,10 @@ static int try_to_merge_one_page(struct vm_area_struct 
> > *vma,
> >                          */
> >                         set_page_stable_node(page, NULL);
> >                         mark_page_accessed(page);
> > +                       if (mapcount)
> > +                               add_zone_page_state(page_zone(page),
> > +                                                   NR_KSM_PAGES_SHARING,
> > +                                                   mapcount);
> >                         err = 0;
> >                 } else if (pages_identical(page, kpage))
> >                         err = replace_page(vma, page, kpage, orig_pte); 
> 
> If you're going to store this per-zone, does it make sense to have it
> show up in /proc/zoneinfo?  meminfo's also getting pretty porky these
> days, so I almost wonder if it should stay in zoneinfo only.

Yes, thanks for pointing out, I will fix it soon. And sorry for the late 
response,there was a bug in my mail client which prevents this mail from being 
filtered out.

Nai

> 
> -- Dave
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
