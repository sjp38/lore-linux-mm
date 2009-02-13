Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A4F8B6B00AA
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 01:15:01 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1D6ExUA000932
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Feb 2009 15:14:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B00A545DD83
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 15:14:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78B5F45DD7F
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 15:14:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 405CDE08004
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 15:14:58 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D80A41DB803F
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 15:14:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] clean up for early_pfn_to_nid
In-Reply-To: <20090212162203.db3f07cb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com> <20090212162203.db3f07cb.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090213151406.77CB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Feb 2009 15:14:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, davem@davemlloft.net, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Declaration of early_pfn_to_nid() is scattered over per-arch include files,
> and it seems it's complicated to know when the declaration is used.
> I think it makes fix-for-memmap-init not easy.
> 
> This patch moves all declaration to include/linux/mm.h
> 
> After this,
>   if !CONFIG_NODES_POPULATES_NODE_MAP && !CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
>      -> Use static definition in include/linux/mm.h
>   else if !CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
>      -> Use generic definition in mm/page_alloc.c
>   else
>      -> per-arch back end function will be called.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

at least, this patch works fine on my ia64 box.

	Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
