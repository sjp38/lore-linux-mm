Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BF9568D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 19:27:37 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAF0RYCf001015
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Nov 2010 09:27:34 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 276F845DE61
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:27:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0177645DE55
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:27:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D3C651DB803B
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:27:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 93D801DB803A
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:27:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] cleanup kswapd()
In-Reply-To: <alpine.LNX.2.00.1011141202430.3460@swampdragon.chaosbits.net>
References: <20101114180505.BEE2.A69D9226@jp.fujitsu.com> <alpine.LNX.2.00.1011141202430.3460@swampdragon.chaosbits.net>
Message-Id: <20101115092712.BEF4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Nov 2010 09:27:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:
> 
> > 
> > Currently, kswapd() function has deeper nest and it slightly harder to
> > read. cleanup it.
> > 
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |   71 +++++++++++++++++++++++++++++++---------------------------
> >  1 files changed, 38 insertions(+), 33 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 8cc90d5..82ffe5f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2364,6 +2364,42 @@ out:
> >  	return sc.nr_reclaimed;
> >  }
> >  
> > +void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> 
> Shouldn't this be
> 
>   static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> 
> ??

Right. thank you.
I'll respin.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
