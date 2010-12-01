Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 037C76B004A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 05:17:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB1AH9RE014028
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 19:17:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1662745DE5E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:17:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EE1F745DE5B
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:17:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D20A7E08004
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:17:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 93371E18006
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:17:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <alpine.DEB.2.00.1011301309240.3134@router.home>
References: <20101130092534.82D5.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011301309240.3134@router.home>
Message-Id: <20101201114226.ABAB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Dec 2010 19:17:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Simon Kirby <sim@hostway.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 30 Nov 2010, KOSAKI Motohiro wrote:
> 
> > This?
> 
> Specifying a parameter to temporarily override to see if this has the
> effect is ok. But this has worked for years now. There must be something
> else going with with reclaim that causes these issues now.

I don't think this has worked. Simon have found the corner case recently,
but it is not new.

So I hope you realize that high order allocation is no free lunch. __GFP_NORETRY
makes no sense really. Even though we have compaction, high order reclaim is still
costly operation.

I don't think SLUB's high order allocation trying is bad idea. but now It 
does more costly trying. that's bad. Also I'm worry about SLUB assume too 
higher end machine. Now Both SLES and RHEL decided to don't use SLUB, 
instead use SLAB. Now linux community is fragmented. If you are still 
interesting SL*B unification, can you please consider to join corner 
case smashing activity?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
