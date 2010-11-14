Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 63E158D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:43:17 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE5hEq9015428
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 14:43:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 179D745DE4E
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:43:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E610445DE4D
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:43:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3EC7E08001
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:43:13 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 913FD1DB8037
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:43:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,vmscan: Reclaim order-0 and compact instead of lumpy reclaim when under light pressure
In-Reply-To: <20101112093742.GA3537@csn.ul.ie>
References: <1289502424-12661-4-git-send-email-mel@csn.ul.ie> <20101112093742.GA3537@csn.ul.ie>
Message-Id: <20101114144155.E01F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 14 Nov 2010 14:43:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Thu, Nov 11, 2010 at 07:07:04PM +0000, Mel Gorman wrote:
> > +	if (COMPACTION_BUILD)
> > +		sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
> > +	else
> > +		sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
> >  
> 
> Gack, I posted the slightly wrong version. This version prevents lumpy
> reclaim ever being used. The figures I posted were for a patch where
> this condition looked like
> 
>         if (COMPACTION_BUILD && priority > DEF_PRIORITY - 2)
>                 sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
>         else
>                 sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;

In all other place, heavy reclaim detection are used folliowing.

	if (priority < DEF_PRIORITY - 2)


So, "priority >= DEF_PRIORITY - 2" is more symmetric, I think. but if you have strong
reason, I don't oppse.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
