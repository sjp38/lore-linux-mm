Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id C28FF6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 09:51:33 -0400 (EDT)
Date: Tue, 1 May 2012 14:47:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] hugetlb: avoid gratuitous BUG_ON in hugetlb_fault() ->
 hugetlb_cow()
Message-ID: <20120501134742.GA9004@csn.ul.ie>
References: <201204291936.q3TJa4Mv008924@farm-0027.internal.tilera.com>
 <alpine.LSU.2.00.1204301308090.2829@eggly.anvils>
 <20120501131413.GA11435@suse.de>
 <201205011333.q41DXsK7026759@farm-0013.internal.tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201205011333.q41DXsK7026759@farm-0013.internal.tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Apr 29, 2012 at 03:04:51PM -0400, Chris Metcalf wrote:
> Commit 66aebce747eaf added code to avoid a race condition by
> elevating the page refcount in hugetlb_fault() while calling
> hugetlb_cow().  However, one code path in hugetlb_cow() includes
> an assertion that the page count is 1, whereas it may now also
> have the value 2 in this path.  Consensus is that this BUG_ON
> has served its purpose, so rather than extending it to cover both
> cases, we just remove it.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

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
