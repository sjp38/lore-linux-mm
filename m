Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAB8Du1E003010
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 11 Nov 2008 17:13:56 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2722A45DD76
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 17:13:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05E3D45DD79
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 17:13:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CE4D1E08001
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 17:13:55 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78B831DB803F
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 17:13:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into pcp
In-Reply-To: <Pine.LNX.4.64.0811071244330.5387@quilx.com>
References: <20081107112722.GE13786@csn.ul.ie> <Pine.LNX.4.64.0811071244330.5387@quilx.com>
Message-Id: <20081111171312.8B32.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 11 Nov 2008 17:13:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Oh, do you mean splitting the list instead of searching? This is how it was
> > originally implement and shot down on the grounds it increased the size of
> > a per-cpu structure.
> 
> The situation may be better with the cpu_alloc stuff. The big pcp array in
> struct zone for all possible processors will be gone and thus the memory
> requirements will be less.

Yup, there are very nicer patch!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
