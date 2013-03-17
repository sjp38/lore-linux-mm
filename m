Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id D417E6B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 10:36:23 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
	<1363525456-10448-4-git-send-email-mgorman@suse.de>
Date: Sun, 17 Mar 2013 07:36:22 -0700
In-Reply-To: <1363525456-10448-4-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Sun, 17 Mar 2013 13:04:09 +0000")
Message-ID: <m2ehfejdp5.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:
>
> To avoid infinite looping for high-order allocation requests kswapd will
> not reclaim for high-order allocations when it has reclaimed at least
> twice the number of pages as the allocation request.

Will this make higher order allocations fail earlier? Or does compaction 
still kick in early enough.

I understand the motivation.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
