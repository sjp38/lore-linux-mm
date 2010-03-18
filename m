Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 236DE600363
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 20:34:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2I0YUPL012533
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Mar 2010 09:34:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4764E45DE70
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:34:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22ED845DE60
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:34:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 01D231DB8044
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:34:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A355C1DB8037
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:34:29 +0900 (JST)
Date: Thu, 18 Mar 2010 09:30:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
Message-Id: <20100318093042.b6b77d8f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003171139280.27268@router.home>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	<1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	<28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	<20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100315112829.GI18274@csn.ul.ie>
	<1268657329.1889.4.camel@barrios-desktop>
	<20100315142124.GL18274@csn.ul.ie>
	<20100316084934.3798576c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361003162000w34cc13ecnbd32840a0df80f95@mail.gmail.com>
	<20100317121551.b619f55b.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003171139280.27268@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Mar 2010 11:41:10 -0500 (CDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Wed, 17 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > Ah, my point is "how use-after-free is detected ?"
> 
> The slab layers do not check for use after free conditions if
> SLAB_DESTROY_BY_RCU is set. It is legal to access the object after a
> kfree() etc as long as the RCU period has not passed.
> 
> > Then, my question is
> > "Does use-after-free check for SLAB_DESTROY_BY_RCU work correctly ?"
> 
> Use after free checks are not performed for SLAB_DESTROY_BY_RCU slabs.
> 
Thank you for kindly clarification. I have no more concerns.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
