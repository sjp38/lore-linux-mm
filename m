Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 46DD16B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 21:54:37 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9F1sYgG020561
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Oct 2009 10:54:35 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4416D2AEA82
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 10:54:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F48345DE4F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 10:54:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F213E1800D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 10:54:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C98E31DB805E
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 10:54:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] mm: move inc_zone_page_state(NR_ISOLATED) to just isolated place
In-Reply-To: <20091013115957.e2871557.akpm@linux-foundation.org>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com> <20091013115957.e2871557.akpm@linux-foundation.org>
Message-Id: <20091015105154.C76A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Oct 2009 10:54:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

> On Fri,  9 Oct 2009 10:06:58 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > This patch series is trivial cleanup and fix of page migration.
> > 
> > 
> > ==========================================================
> > 
> > Christoph pointed out inc_zone_page_state(NR_ISOLATED) should be placed
> > in right after isolate_page().
> 
> The bugfixes are appropriate for 2.6.32 and should be backported into
> -stable too, I think.  I haven't checked to see how long those bugs
> have been present.
> 
> The cleanup is more appropriate for 2.6.33 so I had to switch the order
> of these patches.  Hopefully the bugfixes were not dependent on the
> cleanup.  

Yes, each patches are independent.
[1/3] is cleanup.
[2/3] and [3/3] are bugfixes.

I'm sorry for lack of prudence of patch order.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
