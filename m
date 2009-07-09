Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4E6426B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 19:19:00 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n69Nd87l024548
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Jul 2009 08:39:08 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2047345DE57
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:39:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DB14945DE53
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:39:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BCADD1DB8062
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:39:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 53F971DB805F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:39:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] add buffer cache information to show_free_areas()
In-Reply-To: <alpine.DEB.1.10.0907091635070.17835@gentwo.org>
References: <20090709171027.23C0.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907091635070.17835@gentwo.org>
Message-Id: <20090710083741.17C1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Jul 2009 08:39:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

> On Thu, 9 Jul 2009, KOSAKI Motohiro wrote:
> 
> > Subject: [PATCH] add buffer cache information to show_free_areas()
> >
> > When administrator analysis memory shortage reason from OOM log, They
> > often need to know rest number of cache like pages.
> 
> Maybe:
> 
> "
> It is often useful to know the statistics for all pages that are handled
> like page cache pages when looking at OOM log output.
> 
> Therefore show_free_areas() should also display buffer cache statistics.
> "

Thanks good description. Will fix.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
