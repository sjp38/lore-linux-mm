Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 435FA6B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 18:22:52 -0400 (EDT)
Date: Sat, 13 Aug 2011 00:22:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812222245.GA12739@redhat.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
 <20110812160813.GF2395@linux.vnet.ibm.com>
 <20110812165749.GA29086@redhat.com>
 <20110812170823.GM7959@redhat.com>
 <20110812175206.GB29086@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812175206.GB29086@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 07:52:06PM +0200, Johannes Weiner wrote:
> Do we even need to make this fixed?  It can be unsigned long long for
> now, but I could imagine leaving it up to the user depending how much
> space she is able/willing to invest to save time:
> 
> 	void synchronize_rcu_with(unsigned long time, unsigned int bits)
> 	{
> 		if (generation_counter & ((1 << bits) - 1) == time)
> 			synchronize_rcu();
> 	}
> 
> If you have only 3 bits to store the time, you will synchronize
> falsely to every 8th phase.  Better than nothing, right?

Ok if any of the bits is different we can safely skip it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
