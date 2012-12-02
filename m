Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id AC1986B0044
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 14:45:50 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1496805eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 11:45:49 -0800 (PST)
Date: Sun, 2 Dec 2012 20:45:44 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 2/2, v2] sched: Add RSS filter to NUMA-balancing
Message-ID: <20121202194544.GA20549@gmail.com>
References: <1354464796-14343-1-git-send-email-mingo@kernel.org>
 <1354464796-14343-3-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354464796-14343-3-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


Updated -v2 patch: RSS high-water calculation has a performance 
trick, so mm->hiwater_rss must be used together with get_mm_rss.

Thanks,

	Ingo

--------------------------->
