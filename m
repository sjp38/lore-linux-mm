Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1327E6B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 18:12:34 -0500 (EST)
Date: Thu, 12 Nov 2009 23:12:17 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 0/6] ksm: not quite swapping yet
Message-ID: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a series of six KSM patches against 2.6.32-rc5-mm1, plus the six
earlier "mm: prepare for ksm swapping" patches (and the ksm cond_resched
patch in 2.6.32-rc6-git).

These are all internal housekeeping changes to ksm.c, to minimize the
actual, functional KSM-page swapping patches, coming in a few days.

 include/linux/ksm.h |   24 +
 mm/ksm.c            |  540 +++++++++++++++++++-----------------------
 2 files changed, 266 insertions(+), 298 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
