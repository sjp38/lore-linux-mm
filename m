Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8605F6B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 01:40:32 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 119ED3EE0BC
	for <linux-mm@kvack.org>; Mon,  9 May 2011 14:40:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC40945DE51
	for <linux-mm@kvack.org>; Mon,  9 May 2011 14:40:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D17DC45DE4D
	for <linux-mm@kvack.org>; Mon,  9 May 2011 14:40:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C20FF1DB803B
	for <linux-mm@kvack.org>; Mon,  9 May 2011 14:40:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B8101DB802F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 14:40:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] getdelays: show average CPU/IO/SWAP/RECLAIM delays
In-Reply-To: <20110502140257.GA12780@localhost>
References: <20110502140257.GA12780@localhost>
Message-Id: <20110509144202.163D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 14:40:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

> I find it very handy to show the average delays in milliseconds.
> 
> Example output (on 100 concurrent dd reading sparse files):
> 
> CPU             count     real total  virtual total    delay total  delay average
>                   986     3223509952     3207643301    38863410579         39.415ms
> IO              count    delay total  delay average
>                     0              0              0ms
> SWAP            count    delay total  delay average
>                     0              0              0ms
> RECLAIM         count    delay total  delay average
>                  1059     5131834899              4ms
> dd: read=0, write=0, cancelled_write=0
> 
> CC: Mel Gorman <mel@linux.vnet.ibm.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  Documentation/accounting/getdelays.c |   33 +++++++++++++++----------
>  1 file changed, 20 insertions(+), 13 deletions(-)

Cool.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
