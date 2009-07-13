Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A3716B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 19:12:18 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6DNcv0w020520
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Jul 2009 08:38:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 661BA2AEA81
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:38:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1070745DE4F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:38:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 867711DB803F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:38:56 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 274841DB8041
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:38:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] OOM analysis helper patch series v3
In-Reply-To: <4A5B9D52.3050703@redhat.com>
References: <20090713144924.6257.A69D9226@jp.fujitsu.com> <4A5B9D52.3050703@redhat.com>
Message-Id: <20090714083119.6269.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Jul 2009 08:38:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> KOSAKI Motohiro wrote:
> > ChangeLog
> >  Since v2
> >    - Dropped "[4/5] add isolate pages vmstat" temporary because it become
> >      slightly big. Then, I plan to submit it as another patchset.
> 
> Shame, I really liked that patch :)

Sorry, the modification for migration is slightly big. it is still under
testing on my stress workload testing environment.

I expect it come back at 2-3 days after.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
