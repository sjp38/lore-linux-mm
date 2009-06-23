Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4CCA66B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 01:13:01 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N5DMHX014137
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Jun 2009 14:13:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A48445DE58
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:13:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 22C9F45DE51
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:13:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 060D31DB8038
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:13:22 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AC1461DB805A
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:13:21 +0900 (JST)
Date: Tue, 23 Jun 2009 14:11:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
Message-Id: <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090623135017.220D.A69D9226@jp.fujitsu.com>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	<1245732411.18339.6.camel@alok-dev1>
	<20090623135017.220D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akataria@vmware.com, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jun 2009 14:05:47 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> I'm not sure this unevictable definition is good idea or not. currently
> hugepage isn't only non-account memory, but also various kernel memory doesn't
> account.
> 
> one of drawback is that zone_page_state(UNEVICTABLE) lost to mean #-of-unevictable-pages.
> e.g.  following patch is wrong?
> 
> fs/proc/meminfo.c meminfo_proc_show()
> ----------------------------
> -                K(pages[LRU_UNEVICTABLE]),
> +                K(pages[LRU_UNEVICTABLE]) + hstate->nr_huge_pages,
> 
> 
> Plus, I didn't find any practical benefit in this patch. do you have it?
> or You only want to natural definition?
> 
> I don't have any strong oppose reason, but I also don't have any strong
> agree reason.
> 
I think "don't include Hugepage" is sane. Hugepage is something _special_, now.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
