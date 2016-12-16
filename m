Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB496B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 05:19:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so6369181wmu.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:19:18 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id v129si2721660wma.15.2016.12.16.02.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 02:19:17 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id g23so4400633wme.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:19:17 -0800 (PST)
Date: Fri, 16 Dec 2016 13:19:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/4] mm: add new mmgrab() helper
Message-ID: <20161216101915.GC27758@node>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216095624.GR3107@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216095624.GR3107@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Dec 16, 2016 at 10:56:24AM +0100, Peter Zijlstra wrote:
> But I must say mmget() vs mmgrab() is a wee bit confusing.

mm_count vs mm_users is not very clear too. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
