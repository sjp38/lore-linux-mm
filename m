Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE3CE6B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 21:50:49 -0400 (EDT)
Date: Tue, 13 Jul 2010 20:50:14 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] vmscan: don't subtraction of unsined
In-Reply-To: <20100713182918.EA67.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1007132047001.14067@router.home>
References: <20100709090956.CD51.A69D9226@jp.fujitsu.com> <20100709152851.330bf2b2.akpm@linux-foundation.org> <20100713182918.EA67.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010, KOSAKI Motohiro wrote:

> Christoph, Can we hear your opinion about to add new branch in slab-free path?
> I think this is ok, because reclaim makes a lot of cache miss then branch
> mistaken is relatively minor penalty. thought?

Its on the slow path so I would think that should be okay. But is this
really necessary? Working with the per zone slab reclaim counters is not
enough? We are adding counter after counter that have similar purposes and
the handling gets more complex.

Maybe we can get rid of the code in the slabs instead by just relying on
the difference of the zone counters?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
