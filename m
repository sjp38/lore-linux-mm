Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAD76B00AE
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:20:59 -0500 (EST)
Date: Wed, 1 Dec 2010 16:19:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch]vmscan: make kswapd use a correct order
Message-Id: <20101201161954.aa90e957.akpm@linux-foundation.org>
In-Reply-To: <20101201155854.GA3372@barrios-desktop>
References: <1291172911.12777.58.camel@sli10-conroe>
	<20101201132730.ABC2.A69D9226@jp.fujitsu.com>
	<20101201155854.GA3372@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>


Paging Mel Gorman.  This fix looks pretty thoroughly related to your
"[RFC PATCH 0/3] Prevent kswapd dumping excessive amounts of memory in
response to high-order allocations"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
