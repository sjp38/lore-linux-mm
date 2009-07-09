Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5CF726B0055
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 03:05:50 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n697KVXi019258
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 16:20:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id ACA3E45DE54
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:20:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 84FA845DE4E
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:20:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2340CE1800C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:20:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A706AE1800D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:20:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
In-Reply-To: <20090709144938.23A8.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.1.10.0907071252060.5124@gentwo.org> <20090709144938.23A8.A69D9226@jp.fujitsu.com>
Message-Id: <20090709161712.23B0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 16:20:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > On Mon, 6 Jul 2009, Minchan Kim wrote:
> > 
> > > Anyway, I think it's not a big cost in normal system.
> > > So If you want to add new accounting, I don't have any objection. :)
> > 
> > Lets keep the counters to a mininum. If we can calculate the values from
> > something else then there is no justification for a new counter.
> > 
> > A new counter increases the size of the per cpu structures that exist for
> > each zone and each cpu. 1 byte gets multiplies by the number of cpus and
> > that gets multiplied by the number of zones.
> 
> OK. I'll implement this idea.

Grr, sorry I cancel this opinion. Shem pages can't be calculated 
by minchan's formula.

if those page are mlocked, the page move to unevictable lru. then
this calculation don't account mlocked page. However mlocked tmpfs pages
also make OOM issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
