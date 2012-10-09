Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id C0D4A6B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 12:58:46 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/5] Memory policy corruption fixes -stable
Date: Tue,  9 Oct 2012 17:58:36 +0100
Message-Id: <1349801921-16598-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

This is a backport of the series "Memory policy corruption fixes V2". This
should apply to 3.6-stable, 3.5-stable, 3.4-stable and 3.0-stable without
any difficulty.  It will not apply cleanly to 3.2 but just drop the "revert"
patch and the rest of the series should apply.

I tested 3.6-stable and 3.0-stable with just the revert and trinity breaks
as expected for the mempolicy tests. Applying the full series in both case
allowed trinity to complete successfully. Andi Kleen reported previously
that the series fixed a database performance regression[1].

[1] https://lkml.org/lkml/2012/8/22/585

 include/linux/mempolicy.h |    2 +-
 mm/mempolicy.c            |  137 +++++++++++++++++++++++++++++----------------
 2 files changed, 89 insertions(+), 50 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
