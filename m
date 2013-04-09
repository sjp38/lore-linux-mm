Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id DC9AE6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 13:27:19 -0400 (EDT)
Date: Tue, 9 Apr 2013 17:27:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
In-Reply-To: <1365505625-9460-1-git-send-email-mgorman@suse.de>
Message-ID: <0000013defd666bf-213d70fc-dfbd-4a50-82ed-e9f4f7391b55-000000@email.amazonses.com>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

One additional measure that may be useful is to make kswapd prefer one
specific processor on a socket. Two benefits arise from that:

1. Better use of cpu caches and therefore higher speed, less
serialization.

2. Reduction of the disturbances to one processor.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
