Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id BBDAE6B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 02:53:31 -0500 (EST)
Date: Tue, 8 Jan 2013 16:53:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: swap out anonymous page regardless of laptop_mode
Message-ID: <20130108075327.GB4714@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

Hi Luigi,

Sorry for really really late response.
Today I have a time to look at this problem and it seems to found the problem.
By your help, I can reprocude this problem easily on my KVM machine and this
patch solves the problem.

Could you test below patch? Although this patch is based on recent mmotm,
I guess you can apply it easily to 3.4.
