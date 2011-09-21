Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 630C99000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 13:19:04 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p8LHJ1eV004668
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:19:01 -0700
Received: from yxt3 (yxt3.prod.google.com [10.190.5.195])
	by hpaq2.eem.corp.google.com with ESMTP id p8LHIE4c009534
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:19:00 -0700
Received: by yxt3 with SMTP id 3so1737912yxt.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:18:55 -0700 (PDT)
Date: Wed, 21 Sep 2011 10:18:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: compaction: staticize compact_zone_order
In-Reply-To: <20110921085843.GA16233@july>
Message-ID: <alpine.DEB.2.00.1109211018070.19682@chino.kir.corp.google.com>
References: <20110921085843.GA16233@july>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Sep 2011, Kyungmin Park wrote:

> From: Kyungmin Park <kyungmin.park@samsung.com>
> 
> There's no user to use compact_zone_order. So staticize this function.
> 

s/no user/no user outside of file scope/

> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
