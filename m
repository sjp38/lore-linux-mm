Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 923408D003F
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 16:22:02 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p1MLM0EL004479
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:22:00 -0800
Received: from pvg6 (pvg6.prod.google.com [10.241.210.134])
	by hpaq12.eem.corp.google.com with ESMTP id p1MLLvjX025449
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:21:58 -0800
Received: by pvg6 with SMTP id 6so373352pvg.21
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:21:57 -0800 (PST)
Date: Tue, 22 Feb 2011 13:21:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] break out smaps_pte_entry() from smaps_pte_range()
In-Reply-To: <20110222015340.B0D1C3FC@kernel>
Message-ID: <alpine.DEB.2.00.1102221318300.5929@chino.kir.corp.google.com>
References: <20110222015338.309727CA@kernel> <20110222015340.B0D1C3FC@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 21 Feb 2011, Dave Hansen wrote:

> 
> We will use smaps_pte_entry() in a moment to handle both small
> and transparent large pages.  But, we must break it out of
> smaps_pte_range() first.
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
