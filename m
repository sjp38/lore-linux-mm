Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DEDE98D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 06:16:01 -0500 (EST)
Date: Thu, 10 Feb 2011 11:15:33 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/5] break out smaps_pte_entry() from smaps_pte_range()
Message-ID: <20110210111533.GD17873@csn.ul.ie>
References: <20110209195406.B9F23C9F@kernel> <20110209195408.B08C04D3@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110209195408.B08C04D3@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Feb 09, 2011 at 11:54:08AM -0800, Dave Hansen wrote:
> 
> We will use smaps_pte_entry() in a moment to handle both small
> and transparent large pages.  But, we must break it out of
> smaps_pte_range() first.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
