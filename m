Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 60F786B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 16:03:33 -0500 (EST)
Received: by pablf10 with SMTP id lf10so30425589pab.6
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 13:03:33 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id jc4si12735945pbd.12.2015.02.23.13.03.32
        for <linux-mm@kvack.org>;
        Mon, 23 Feb 2015 13:03:32 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 0/6] the big khugepaged redesign
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
Date: Mon, 23 Feb 2015 13:03:22 -0800
In-Reply-To: <1424696322-21952-1-git-send-email-vbabka@suse.cz> (Vlastimil
	Babka's message of "Mon, 23 Feb 2015 13:58:36 +0100")
Message-ID: <87lhjouyqt.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

Vlastimil Babka <vbabka@suse.cz> writes:

> This has been already discussed as a good
> idea and a RFC has been posted by Alex Thorlton last October [5].

In my opinion it's a very bad idea. It heavily penalizes the single
threaded application case, which is quite important. And it
would likely lead to even larger latencies on the application
base, even for the multithreaded case, as there is no good way
anymore to hide blocking latencies in the process.

The current single thead khugepaged has various issues, but this would
just make it much worse.

IMHO it's useless to do much here without a lot of data first
to identify the actual problems. Doing things first without analysis 
first seems totally backwards.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
