Received: from ucla.edu ([149.142.156.27])
	by panther.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id MAA18716
	for <linux-mm@kvack.org>; Thu, 11 Jan 2001 12:52:49 -0800 (PST)
Message-ID: <3A5E1D21.2DDB492C@ucla.edu>
Date: Thu, 11 Jan 2001 12:52:49 -0800
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: pre2 swap_out() changes
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Does this make sensee,specially, the last two lines?
	Maybe 2.4.1-pre3 will shed some light, but I see that Marcelo basically
reverted this in his patch this morning...

-	onlist = PageActive(page);
 	/* Don't look at this pte if it's been accessed recently. */
 	if (ptep_test_and_clear_young(page_table)) {
-		age_page_up(page);
-		goto out_failed;
+		page->age += PAGE_AGE_ADV;
+		if (page->age > PAGE_AGE_MAX)
+			page->age = PAGE_AGE_MAX;
+		return;
 	}
-	if (!onlist)
-		/* The page is still mapped, so it can't be freeable... */
-		age_page_down_ageonly(page);
-
-	/*
-	 * If the page is in active use by us, or if the page
-	 * is in active use by others, don't unmap it or
-	 * (worse) start unneeded IO.
-	 */
-	if (page->age > 0)
-		goto out_failed;

-BenRI
-- 
q
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
