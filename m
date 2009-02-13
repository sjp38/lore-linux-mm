Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 896796B00AB
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 01:15:22 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1D6FJNv021344
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Feb 2009 15:15:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E8E9045DE52
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 15:15:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B60A345DD72
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 15:15:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 55DAB1DB8037
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 15:15:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D3C2E18001
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 15:15:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] fix memmap init for handling memory hole
In-Reply-To: <20090212162421.65bb7aa2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com> <20090212162421.65bb7aa2.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090213151455.77CE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Feb 2009 15:15:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, davem@davemlloft.net, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, early_pfn_in_nid(PFN, NID) may returns false if PFN is a hole.
> and memmap initialization was not done. This was a trouble for
> sparc boot.
> 
> To fix this, the PFN should be initialized and marked as PG_reserved.
> This patch changes early_pfn_in_nid() return true if PFN is a hole.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

at least, this patch works fine on my ia64 box.

	Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
