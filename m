Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E70E48D003F
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 16:22:10 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p1MLM9DR018100
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:22:09 -0800
Received: from pva4 (pva4.prod.google.com [10.241.209.4])
	by kpbe14.cbf.corp.google.com with ESMTP id p1MLL2xf007312
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:22:07 -0800
Received: by pva4 with SMTP id 4so881185pva.2
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:22:07 -0800 (PST)
Date: Tue, 22 Feb 2011 13:22:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] teach smaps_pte_range() about THP pmds
In-Reply-To: <20110222015343.41586948@kernel>
Message-ID: <alpine.DEB.2.00.1102221321000.5929@chino.kir.corp.google.com>
References: <20110222015338.309727CA@kernel> <20110222015343.41586948@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 21 Feb 2011, Dave Hansen wrote:

> 
> v2 - used mm->page_table_lock to fix up locking bug that
> 	Mel pointed out.  Also remove Acks since things
> 	got changed significantly.
> 
> This adds code to explicitly detect  and handle
> pmd_trans_huge() pmds.  It then passes HPAGE_SIZE units
> in to the smap_pte_entry() function instead of PAGE_SIZE.
> 
> This means that using /proc/$pid/smaps now will no longer
> cause THPs to be broken down in to small pages.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
