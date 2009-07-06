Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4641E6B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 23:50:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n664OMKL027016
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 6 Jul 2009 13:24:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 43B9A45DE5D
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 13:24:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 20C7345DE55
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 13:24:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 08E921DB8041
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 13:24:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A76321DB803A
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 13:24:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] add buffer cache information to show_free_areas()
In-Reply-To: <28c262360907050716x28671070of7ab21556213b337@mail.gmail.com>
References: <20090705182337.08F9.A69D9226@jp.fujitsu.com> <28c262360907050716x28671070of7ab21556213b337@mail.gmail.com>
Message-Id: <20090706132340.52B6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  6 Jul 2009 13:24:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > @@ -2118,7 +2118,7 @@ void show_free_areas(void)
> > ? ? ? ?printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
> > ? ? ? ? ? ? ? ?" inactive_file:%lu"
> > ? ? ? ? ? ? ? ?" unevictable:%lu"
> > - ? ? ? ? ? ? ? " dirty:%lu writeback:%lu unstable:%lu\n"
> > + ? ? ? ? ? ? ? " dirty:%lu writeback:%lu buffer:%lu unstable:%lu\n"
> > ? ? ? ? ? ? ? ?" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> > ? ? ? ? ? ? ? ?" mapped:%lu pagetables:%lu bounce:%lu\n",
> > ? ? ? ? ? ? ? ?global_page_state(NR_ACTIVE_ANON),
> > @@ -2128,6 +2128,7 @@ void show_free_areas(void)
> > ? ? ? ? ? ? ? ?global_page_state(NR_UNEVICTABLE),
> > ? ? ? ? ? ? ? ?global_page_state(NR_FILE_DIRTY),
> > ? ? ? ? ? ? ? ?global_page_state(NR_WRITEBACK),
> > + ? ? ? ? ? ? ? K(nr_blockdev_pages()),
> 
> Why do you show the number with kilobyte unit ?
> Others are already number of pages.
> 
> Do you have any reason ?

Good catch. this is simple mistake.
I'll fix it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
