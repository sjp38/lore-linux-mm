Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1466C90010C
	for <linux-mm@kvack.org>; Mon,  2 May 2011 06:14:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3201C3EE0C5
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:14:47 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB89045DE74
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:14:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6D8545DE5F
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:14:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FEECEF805F
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:14:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AF94EF805D
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:14:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation failures
In-Reply-To: <20110501163737.GB3204@barrios-desktop>
References: <20110501163542.GA3204@barrios-desktop> <20110501163737.GB3204@barrios-desktop>
Message-Id: <20110502191535.2D55.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  2 May 2011 19:14:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

> On Mon, May 02, 2011 at 01:35:42AM +0900, Minchan Kim wrote:
>  
> > Do you see my old patch? The patch want't incomplet but it's not bad for showing an idea.
>                                      ^^^^^^^^^^^^^^^^
>                               typo : wasn't complete

I think your idea is eligible. Wu's approach may increase throughput but
may decrease latency. So, do you have a plan to finish the work?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
