Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 75B106B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:42:25 -0400 (EDT)
Date: Mon, 14 May 2012 22:42:19 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/slab: remove duplicate check
Message-ID: <20120514204219.GC1406@cmpxchg.org>
References: <1336727769-19555-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336727769-19555-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, May 11, 2012 at 05:16:09PM +0800, Gavin Shan wrote:
> While allocateing pages using buddy allocator, the compound page
> is probably split up to free pages. Under the circumstance, the
> compound page should be destroied by function destroy_compound_page().
> However, there has duplicate check to judge if the page is compound
> one.
> 
> The patch removes the duplicate check since the function compound_order()
> will returns 0 while the page hasn't PG_head set in function destroy_compound_page().
> That's to say, the function destroy_compound_page() needn't check
> PG_head any more through function PageHead().
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Looks good!

But the slab in the subject suggests it would not affect other parts
of mm, while it actually affects THP, too.  Should probably be
removed?

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
