Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D18628D003F
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 16:22:07 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p1MLM3sm028495
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:22:04 -0800
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz1.hot.corp.google.com with ESMTP id p1MLLui3022324
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:22:02 -0800
Received: by pwj4 with SMTP id 4so249269pwj.16
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:22:02 -0800 (PST)
Date: Tue, 22 Feb 2011 13:21:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/5] pass pte size argument in to smaps_pte_entry()
In-Reply-To: <20110222015342.5DD9FC72@kernel>
Message-ID: <alpine.DEB.2.00.1102221320010.5929@chino.kir.corp.google.com>
References: <20110222015338.309727CA@kernel> <20110222015342.5DD9FC72@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 21 Feb 2011, Dave Hansen wrote:

> 
> This patch adds an argument to the new smaps_pte_entry()
> function to let it account in things other than PAGE_SIZE
> units.  I changed all of the PAGE_SIZE sites, even though
> not all of them can be reached for transparent huge pages,
> just so this will continue to work without changes as THPs
> are improved.
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
