Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8D7A36B00AE
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 03:18:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J7Ij4e026514
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Mar 2010 16:18:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FC2745DE60
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:18:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E5CA45DE79
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:18:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 087B3E18003
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:18:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D78721DB803B
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:18:41 +0900 (JST)
Date: Fri, 19 Mar 2010 16:15:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] pagemap: add #ifdefs CONFIG_HUGETLB_PAGE on code
 walking hugetlb vma
Message-Id: <20100319161504.2c5c65b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100319065334.GB12389@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1268979996-12297-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20100319152934.c4243698.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319065334.GB12389@spritzerA.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010 15:53:34 +0900
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Fri, Mar 19, 2010 at 03:29:34PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Fri, 19 Mar 2010 15:26:35 +0900
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > 
> > > If !CONFIG_HUGETLB_PAGE, pagemap_hugetlb_range() is never called.
> > > So put it (and its calling function) into #ifdef block.
> > > 
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > 
> > Hmm? What is benefit ? Is this broken now ?
> > 
> 
> Not broken, but this is needed to avoid build error with patch 2/2 applied,
> where I move huge_pte_offset() (not defined when !HUGETLB_PAGE)
> into pagemap_hugetlb_range().
> 

I think this should be merged with 2/2....if necessary.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
