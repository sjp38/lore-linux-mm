Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1ECC98D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 03:06:50 -0400 (EDT)
Date: Mon, 1 Nov 2010 16:06:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: vmstat: Use a single setter function and callback for adjusting percpu thresholds
In-Reply-To: <1288169256-7174-3-git-send-email-mel@csn.ul.ie>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie> <1288169256-7174-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20101101023816.6068.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> reduce_pgdat_percpu_threshold() and restore_pgdat_percpu_threshold()
> exist to adjust the per-cpu vmstat thresholds while kswapd is awake to
> avoid errors due to counter drift. The functions duplicate some code so
> this patch replaces them with a single set_pgdat_percpu_threshold() that
> takes a callback function to calculate the desired threshold as a
> parameter.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
