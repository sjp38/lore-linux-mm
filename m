Received: from atlas.iskon.hr (atlas.iskon.hr [213.191.131.6])
	by inje.iskon.hr (8.9.3/8.9.3/Debian 8.9.3-6) with ESMTP id VAA21315
	for <linux-mm@kvack.org>; Sun, 7 Jan 2001 21:41:15 +0100
Subject: page_launder() questions...
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 07 Jan 2001 21:41:14 +0100
Message-ID: <87ofxj9jth.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In page_launder():

		/* First time through? Move it to the back of the list */
		if (!launder_loop) {
			list_del(page_lru);
			list_add(page_lru, &inactive_dirty_list);
			UnlockPage(page);
			continue;
		}

Well, it has just found a dirty page and instead of writing it out it
skips it and continues scanning. I don't get it!

Also, all comments speak about swap cache pages, but if I understand
correctly, now even "normal" page cache pages get the dirty bit when
dirtied, so they should also be written out in the page_launder()
function, right?
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
