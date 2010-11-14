Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BB7058D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 01:02:07 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE6257V010702
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 15:02:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D910045DE7D
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 15:02:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B5DE545DE70
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 15:02:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 99A581DB8037
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 15:02:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37E231DB803F
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 15:02:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,vmscan: Reclaim order-0 and compact instead of lumpy reclaim when under light pressure
In-Reply-To: <20101112093742.GA3537@csn.ul.ie>
References: <1289502424-12661-4-git-send-email-mel@csn.ul.ie> <20101112093742.GA3537@csn.ul.ie>
Message-Id: <20101114150039.E028.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 14 Nov 2010 15:02:03 +0900 (JST)
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

Can you please tell us your opinition which is better 1) automatically turn lumby on
by priority (this approach) 2) introduce GFP_LUMPY (andrea proposed). I'm not
sure which is better, then I'd like to hear both pros/cons concern.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
