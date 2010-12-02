Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E848F6B0071
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:39:59 -0500 (EST)
Date: Thu, 2 Dec 2010 08:39:55 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101202093337.1573.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1012020836590.27798@router.home>
References: <20101201114226.ABAB.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1012010910450.2989@router.home> <20101202093337.1573.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 2010, KOSAKI Motohiro wrote:

> So I think we have multiple option
>
> 1) reduce slub_max_order and slub only use safely order
> 2) slub don't invoke reclaim when high order tryal allocation
>    (ie turn off GFP_WAIT and turn on GFP_NOKSWAPD)
> 3) slub pass new hint to reclaim and reclaim don't work so aggressively if
>    such hint is passwd.
>
>
> So I have one question. I thought (2) is most nature. but now slub doesn't.

2) so far has not been available. GFP_NOKSWAPD does not exist upstream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
