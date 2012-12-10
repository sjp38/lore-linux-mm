Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 71B786B0070
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 13:41:57 -0500 (EST)
Message-ID: <50C62CE7.2000306@redhat.com>
Date: Mon, 10 Dec 2012 13:41:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [GIT TREE] Unified NUMA balancing tree, v3
References: <1354839566-15697-1-git-send-email-mingo@kernel.org> <alpine.LFD.2.02.1212101902050.4422@ionos>
In-Reply-To: <alpine.LFD.2.02.1212101902050.4422@ionos>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 12/10/2012 01:22 PM, Thomas Gleixner wrote:

> So autonuma and numacore are basically on the same page, with a slight
> advantage for numacore in the THP enabled case. balancenuma is closer
> to mainline than to autonuma/numacore.

Indeed, when the system is fully loaded, numacore does very well.

The main issues that have been observed with numacore are when
the system is only partially loaded. Something strange seems to
be going on that causes performance regressions in that situation.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
