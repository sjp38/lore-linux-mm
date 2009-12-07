Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5C52560021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 04:25:35 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB79PVA9000425
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 7 Dec 2009 18:25:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5254945DE4D
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 18:25:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 32CC745DE50
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 18:25:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C3C81DB803E
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 18:25:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C22431DB8038
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 18:25:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/7] some page_referenced() improvement
In-Reply-To: <20091204173233.5891.A69D9226@jp.fujitsu.com>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com>
Message-Id: <20091207182442.E94D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Dec 2009 18:25:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

> Hi
> 
> here is my refactoring and improvement patchset of page_referenced().
> I think it solve Larry's AIM7 scalability issue.
> 
> I'll test this patches on stress workload at this weekend. but I hope to
> receive guys review concurrently.

OK. this patches survived my stress workload correctly for two days of last weekend.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
