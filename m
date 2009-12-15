Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6C4A46B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 19:49:30 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF0nRM6014713
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 09:49:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BBF545DE52
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:49:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 59B6945DE4E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:49:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 438091DB8045
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:49:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EFB031DB803E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:49:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
In-Reply-To: <1260810481.6666.13.camel@dhcp-100-19-198.bos.redhat.com>
References: <20091211164651.036f5340@annuminas.surriel.com> <1260810481.6666.13.camel@dhcp-100-19-198.bos.redhat.com>
Message-Id: <20091215094815.CDBB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 15 Dec 2009 09:49:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> On Fri, 2009-12-11 at 16:46 -0500, Rik van Riel wrote:
> 
> Rik, the latest patch appears to have a problem although I dont know
> what the problem is yet.  When the system ran out of memory we see
> thousands of runnable processes and 100% system time:
> 
> 
>  9420  2  29824  79856  62676  19564    0    0     0     0 8054  379  0 
> 100  0  0  0
> 9420  2  29824  79368  62292  19564    0    0     0     0 8691  413  0 
> 100  0  0  0
> 9421  1  29824  79780  61780  19820    0    0     0     0 8928  408  0 
> 100  0  0  0
> 
> The system would not respond so I dont know whats going on yet.  I'll
> add debug code to figure out why its in that state as soon as I get
> access to the hardware.
> 
> Larry

There are 9421 running processces. it mean concurrent task limitation
don't works well. hmm?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
