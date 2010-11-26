Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7CAEB8D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:07:07 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAQ0743i008441
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 26 Nov 2010 09:07:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75F1045DE5B
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 09:07:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 55E8145DE57
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 09:07:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A7D1E08002
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 09:07:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E2AC01DB803E
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 09:07:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101125180959.F462.A69D9226@jp.fujitsu.com>
References: <20101125090328.GB14180@hostway.ca> <20101125180959.F462.A69D9226@jp.fujitsu.com>
Message-Id: <20101126090656.B6C7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 26 Nov 2010 09:07:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> Subject: [PATCH] vmscan: don't rewakeup kswapd if zone memory was exhaust
> 
> ---
>  mm/vmscan.c |   18 +++++++++++-------
>  1 files changed, 11 insertions(+), 7 deletions(-)

Ugh, this is buggy. please ignore. 

sorry.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
