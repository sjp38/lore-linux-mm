Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B47FD6B009B
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 21:55:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9C1trR0027772
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Oct 2010 10:55:53 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ED55E45DE4E
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 10:55:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C29D445DE4F
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 10:55:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AABA91DB8041
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 10:55:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 611561DB803B
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 10:55:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <20101008090427.GB5327@balbir.in.ibm.com>
References: <20101008104852.803E.A69D9226@jp.fujitsu.com> <20101008090427.GB5327@balbir.in.ibm.com>
Message-Id: <20101012104701.AD2B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Oct 2010 10:55:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Hi

> > -#define RECLAIM_DISTANCE 20
> > +#define RECLAIM_DISTANCE 30
> >  #endif
> >  #ifndef PENALTY_FOR_NODE_WITH_CPUS
> >  #define PENALTY_FOR_NODE_WITH_CPUS	(1)
> 
> I am not sure if this makes sense, since RECLAIM_DISTANCE is supposed
> to be a hardware parameter. Could you please help clarify what the
> access latency of a node with RECLAIM_DISTANCE 20 to that of a node
> with RECLAIM_DISTANCE 30 is? Has the hardware definition of reclaim
> distance changed?

Recently, Intel/AMD implemented QPI/Hypertransport on their cpus. Then, 
commodity server's average node distance dramatically changed and our threshold
became typical case unfit.

So, my intention is, commodity server continue to don't use zone_reclaim_mode.
because their workload haven't been changed. 

30 itself don't have strong meaning.

> I suspect the side effect is the zone_reclaim_mode is not set to 1 on
> bootup for the 2-4 socket machines you mention, which results in
> better VM behaviour?

It depend on workload. If you are using file/web/emal server (i.e. most common case),
it's better. but HPC workload don't works so fine.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
