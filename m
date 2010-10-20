Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6C39E6B00C0
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:32:43 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K2WdBE029581
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Oct 2010 11:32:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B249F45DE4E
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:32:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FDFF45DE4F
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:32:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D0241DB8040
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:32:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BA661DB8038
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:32:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: oom_killer crash linux system
In-Reply-To: <1287540415.2069.1.camel@myhost>
References: <20101020013553.GA7428@localhost> <1287540415.2069.1.camel@myhost>
Message-Id: <20101020112828.1818.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 20 Oct 2010 11:32:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, figo1802 <figo1802@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> > > page_add_file_rmap() just counts an event where mapcount goes 0->1. 
> > > Even if thousands process shares  a page,  it's just counted into file_mapped as 1.
> > > 
> > > Then, there are 480MB of mapped file caches. Do I miss something ?
> > > 
> > > Anyway, sum-of-all-lru-of-highmem is 480MB smaller than present pages.
> > > and isolated(anon/file) is 0kB.
> > > (NORMAL has similar problem)
> > 
> > hugetlb files? But it's a desktop box. Figo, what's your meminfo?
> > 
> > The GEM objects may be files not in LRU, however they should be
> > accounted into shmem.
> > 
> > Figo, would you run "page-types -r" for some clues? It can be compiled
> > from the kernel tree:
> > 
> >         cd linux
> >         make Documentation/vm
> >         sudo Documentation/vm/page-types -r
> 
> hi fengguang,
> here is the "page-types -r" result:
> 
>              flags	page-count       MB  symbolic-flags
> long-symbolic-flags
> 0x0000000000005828	     74342      290 ___U_l_____Ma_b___________________ uptodate,lru,mmap,anonymous,swapbacked
> 0x0000000000005868	    373077     1457 ___U_lA____Ma_b___________________ uptodate,lru,active,mmap,anonymous,swapbacked

1457+290=1747MB. that's ok. and this is very different result with your
previous oom log.

can you please try 1) invoke oom 2) get page-types -r again. I'm curious
that oom makes page accounting lost again. I mean, please send us oom 
log and "page-types -r" result.

thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
