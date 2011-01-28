Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CFC238D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:24:19 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9685B3EE0B5
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:24:17 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D4FF45DE50
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:24:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 09AA245DE5D
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:24:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D63EE1DB8043
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:24:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 73EBB1DB803A
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:24:13 +0900 (JST)
Date: Fri, 28 Jan 2011 17:17:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
Message-Id: <20110128171744.b7b37703.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110128081928.GC5054@balbir.in.ibm.com>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
	<AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
	<AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
	<AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
	<20110128064851.GB5054@balbir.in.ibm.com>
	<AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
	<20110128165605.3cbe5208.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128081928.GC5054@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 13:49:28 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-28 16:56:05]:
 
> > BTW, it seems this doesn't work when some apps use huge shmem.
> > How to handle the issue ?
> >
> 
> Could you elaborate further? 
> 
==
static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
{
        unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
        unsigned long file_lru = zone_page_state(zone, NR_INACTIVE_FILE) +
                zone_page_state(zone, NR_ACTIVE_FILE);

        /*
         * It's possible for there to be more file mapped pages than
         * accounted for by the pages on the file LRU lists because
         * tmpfs pages accounted for as ANON can also be FILE_MAPPED
         */
        return (file_lru > file_mapped) ? (file_lru - file_mapped) : 0;
}
==

Did you read ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
