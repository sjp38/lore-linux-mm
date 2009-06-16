Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9CD986B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 13:24:10 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090616132304.05a7f490@binnacle.cx>
Date: Tue, 16 Jun 2009 13:24:27 -0400
From: starlight@binnacle.cx
Subject: Re: QUESTION: can netdev_alloc_skb() errors be reduced
  by tuning?
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, ebmunson@us.ibm.com, agl@us.ibm.com, apw@canonical.com, wli@movementarian.org
List-ID: <linux-mm.kvack.org>

>Tried increasing a few /proc/slabinfo tuneable parameters today
>and this appears to have fixed the issue so far today.

Spoke too soon.  A burst of allocation fails appeared
a some incoming data was lost.  'e1000e' system had
no problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
