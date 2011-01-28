Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 43C3E8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 07:03:08 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p0SC2nmX018233
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 23:02:49 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0SC2nBT2228426
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 23:02:49 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0SC2nEu008337
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 23:02:49 +1100
Date: Fri, 28 Jan 2011 17:32:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
Message-ID: <20110128120247.GE5054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
 <20110125051015.13762.13429.stgit@localhost6.localdomain6>
 <AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
 <AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
 <AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
 <20110128064851.GB5054@balbir.in.ibm.com>
 <AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
 <20110128165605.3cbe5208.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128081928.GC5054@balbir.in.ibm.com>
 <20110128171744.b7b37703.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110128171744.b7b37703.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-28 17:17:44]:

> On Fri, 28 Jan 2011 13:49:28 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-28 16:56:05]:
> 
> > > BTW, it seems this doesn't work when some apps use huge shmem.
> > > How to handle the issue ?
> > >
> > 
> > Could you elaborate further? 
> > 
> ==
> static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
> {
>         unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
>         unsigned long file_lru = zone_page_state(zone, NR_INACTIVE_FILE) +
>                 zone_page_state(zone, NR_ACTIVE_FILE);
> 
>         /*
>          * It's possible for there to be more file mapped pages than
>          * accounted for by the pages on the file LRU lists because
>          * tmpfs pages accounted for as ANON can also be FILE_MAPPED
>          */
>         return (file_lru > file_mapped) ? (file_lru - file_mapped) : 0;
> }

Yes, I did :) The word huge confused me. I am not sure if there is an
easy accounting fix for this one, though given the approximate nature
of the control, I am not sure it would matter very much. But you do
have a very good point.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
