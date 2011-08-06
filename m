Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 222DA6B00EE
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 14:00:22 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 0 of 3] THP: mremap support and TLB optimization #3
Message-Id: <patchbomb.1312649882@localhost>
Date: Sat, 06 Aug 2011 18:58:02 +0200
From: aarcange@redhat.com
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Hello everyone,

here a third version of the mremap optimizations following the reviews on the
list. The requested tristate cleanup I didn't do yet because I don't like to
call more external functions than needed during mremap. 

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
