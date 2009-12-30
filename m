Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C7CF160021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 07:54:09 -0500 (EST)
Date: Wed, 30 Dec 2009 21:53:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] memcg: add anon_scan_ratio to memory.stat file
In-Reply-To: <20091229140957.GR3601@balbir.in.ibm.com>
References: <20091228164857.A690.A69D9226@jp.fujitsu.com> <20091229140957.GR3601@balbir.in.ibm.com>
Message-Id: <20091230215052.1A13.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-12-28 16:49:27]:
> 
> > anon_scan_ratio feature doesn't only useful for global VM pressure
> > analysis, but it also useful for memcg memroy pressure analysis.
> > 
> > Then, this patch add anon_scan_ratio field to memory.stat file too.
> > 
> > Instead, following debug statistics was removed. It isn't so user and/or
> > developer friendly.
> > 
> > 	- recent_rotated_anon
> > 	- recent_rotated_file
> > 	- recent_scanned_anon
> > 	- recent_scanned_file
> 
> I've been using these to look at statistics - specifically reclaim
> data on my developer kernels.

ok, I'll drop removing part. just add anon_scan_ratio.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
