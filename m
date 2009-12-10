Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C4DD6B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:28:53 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7Sp5P010809
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:28:51 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BB86145DE51
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:28:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 99E6845DE50
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:28:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E4EE1DB8042
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:28:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 214151DB803E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:28:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v2  0/8] vmscan: AIM7 scalability improvement 
Message-Id: <20091210154822.2550.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Dec 2009 16:28:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Larry Woodman reported current VM has big performance regression when
AIM7 benchmark. It use very much processes and fork/exit/page-fault frequently.
(i.e. it makes serious lock contention of ptelock and anon_vma-lock.)

At 2.6.28, we removed calc_reclaim_mapped() and it made vmscan, then
vmscan always call page_referenced() although VM pressure is low.
It increased lock contention more, unfortunately.


Larry, can you please try this patch series on your big box?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
