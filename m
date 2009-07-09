Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 76EBD6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 01:36:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n695oF7J031872
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 14:50:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CD4C45DE51
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:50:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 33B3445DE55
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:50:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DFB81DB803C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:50:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B2BC21DB803A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:50:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
In-Reply-To: <alpine.DEB.1.10.0907071252060.5124@gentwo.org>
References: <28c262360907050827y577c3859g5e05e82935e96010@mail.gmail.com> <alpine.DEB.1.10.0907071252060.5124@gentwo.org>
Message-Id: <20090709144938.23A8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 14:50:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 6 Jul 2009, Minchan Kim wrote:
> 
> > Anyway, I think it's not a big cost in normal system.
> > So If you want to add new accounting, I don't have any objection. :)
> 
> Lets keep the counters to a mininum. If we can calculate the values from
> something else then there is no justification for a new counter.
> 
> A new counter increases the size of the per cpu structures that exist for
> each zone and each cpu. 1 byte gets multiplies by the number of cpus and
> that gets multiplied by the number of zones.

OK. I'll implement this idea.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
