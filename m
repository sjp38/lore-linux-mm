Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4F59C6B0055
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 00:59:54 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n695DrfS001554
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 14:13:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1607245DE55
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:13:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD26A45DE4F
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:13:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06A661DB8042
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:13:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AD2721DB803B
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:13:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
In-Reply-To: <20090707135656.GB9444@localhost>
References: <20090707102106.0C66.A69D9226@jp.fujitsu.com> <20090707135656.GB9444@localhost>
Message-Id: <20090709141319.23A2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 14:13:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

> On Tue, Jul 07, 2009 at 09:22:48AM +0800, KOSAKI Motohiro wrote:
> > > On Sun, Jul 05, 2009 at 08:21:20PM +0800, KOSAKI Motohiro wrote:
> > > > > On Sun, Jul 05, 2009 at 05:26:18PM +0800, KOSAKI Motohiro wrote:
> 
> > @@ -2118,9 +2118,9 @@ void show_free_areas(void)
> >  	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
> >  		" inactive_file:%lu unevictable:%lu\n"
> >  		" isolated_anon:%lu isolated_file:%lu\n"
> > -		" dirty:%lu writeback:%lu buffer:%lu unstable:%lu\n"
> > +		" dirty:%lu writeback:%lu buffer:%lu shmem:%lu\n"
> 
> btw, nfs unstable pages are related to writeback pages, so it may be
> better to put "unstable" right after "writeback" (as it was)?

OK, will fix.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
