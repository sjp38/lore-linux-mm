Received: from atlas.iskon.hr (atlas.iskon.hr [213.191.131.6])
	by inje.iskon.hr (8.9.3/8.9.3/Debian 8.9.3-6) with ESMTP id VAA20607
	for <linux-mm@kvack.org>; Sun, 7 Jan 2001 21:38:00 +0100
Subject: swap_out() question...
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 07 Jan 2001 21:29:06 +0100
Message-ID: <87wvc79kdp.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the swap_out() function in mm/vmscan.c there is this chunk of code:

	onlist = PageActive(page);
	/* Don't look at this pte if it's been accessed recently. */
	if (ptep_test_and_clear_young(page_table)) {
		age_page_up(page);
		goto out_failed;
	}
	if (!onlist)
		/* The page is still mapped, so it can't be freeable... */
		age_page_down_ageonly(page);

Now I don't understand the last comment. It speaks about mapped page
but we have only tested if a page is active or no. Also if ageing the
page gets it age down to zero page will be freeable indeed. What's
wrong with that comment?

Also why are we aging page down only if it is not active?

Rik and other mm guys, could you comment on this?
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
