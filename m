Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E60F16B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:56:24 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id q186so15087719itb.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 01:56:24 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 79si5434946ioo.42.2016.12.16.01.56.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 01:56:24 -0800 (PST)
Date: Fri, 16 Dec 2016 10:56:24 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/4] mm: add new mmgrab() helper
Message-ID: <20161216095624.GR3107@twins.programming.kicks-ass.net>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216082202.21044-1-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Dec 16, 2016 at 09:21:59AM +0100, Vegard Nossum wrote:
> Apart from adding the helper function itself, the rest of the kernel is
> converted mechanically using:
> 
>   git grep -l 'atomic_inc.*mm_count' | xargs sed -i 's/atomic_inc(&\(.*\)->mm_count);/mmgrab\(\1\);/'
>   git grep -l 'atomic_inc.*mm_count' | xargs sed -i 's/atomic_inc(&\(.*\)\.mm_count);/mmgrab\(\&\1\);/'
> 
> This is needed for a later patch that hooks into the helper, but might be
> a worthwhile cleanup on its own.

Given the desire to replace all refcounting with a specific refcount
type, this seems to make sense.

FYI: http://www.openwall.com/lists/kernel-hardening/2016/12/07/8

But I must say mmget() vs mmgrab() is a wee bit confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
