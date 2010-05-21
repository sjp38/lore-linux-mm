Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC7336B01AF
	for <linux-mm@kvack.org>; Fri, 21 May 2010 12:25:33 -0400 (EDT)
Date: Fri, 21 May 2010 13:25:12 -0300
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at
 first
Message-ID: <20100521162512.GB7595@khazad-dum.debian.net>
References: <20100519174327.9591.A69D9226@jp.fujitsu.com>
 <alpine.DEB.1.00.1005201822120.19421@tigran.mtv.corp.google.com>
 <20100521103935.1E56.A69D9226@jp.fujitsu.com>
 <alpine.DEB.1.00.1005201859260.23122@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.1005201859260.23122@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 20 May 2010, Hugh Dickins wrote:
> If you really want to test some workload on 2.6.28 to see if it too
> works better with your fix, I won't stop you - but I'd much prefer
> you to be applying your mind to 2.6.35 and 2.6.36!

And sending it to -stable (after merged in mainline) if it should be on
2.6.32/33/34, please.

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
