Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 334256B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 10:53:18 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 08/10] mm: vmscan: Have kswapd shrink slab only once per priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
	<1363525456-10448-9-git-send-email-mgorman@suse.de>
Date: Sun, 17 Mar 2013 07:53:10 -0700
In-Reply-To: <1363525456-10448-9-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Sun, 17 Mar 2013 13:04:14 +0000")
Message-ID: <m2wqt6hycp.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:

> If kswaps fails to make progress but continues to shrink slab then it'll
> either discard all of slab or consume CPU uselessly scanning shrinkers.
> This patch causes kswapd to only call the shrinkers once per priority.

Great. This was too aggressive for a long time. Probably still needs
more intelligence in the shrinkers itself to be really good though
(e.g. the old defrag heuristics in dcache)

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
