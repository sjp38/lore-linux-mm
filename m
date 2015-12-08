Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9214F6B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 01:18:10 -0500 (EST)
Received: by wmww144 with SMTP id w144so168157985wmw.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 22:18:10 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id cb2si2306449wjc.79.2015.12.07.22.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 22:18:09 -0800 (PST)
Date: Tue, 8 Dec 2015 07:18:08 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH V3][for-next] mm: add a new vector based madvise syscall
Message-ID: <20151208061807.GO15533@two.firstfloor.org>
References: <7c6ce0f1fe29fc22faf72134f4e2674da8d3d149.1449532062.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c6ce0f1fe29fc22faf72134f4e2674da8d3d149.1449532062.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>

> +	if (behavior != MADV_DONTNEED && behavior != MADV_FREE)
> +		return -EINVAL;

This limitations is kind of lame and makes it a special purpose hack.

It will also cause backwards compatibility issues if it needs
to be extended later.

How hard would it be to support all of madvise vectored?

That would also give much cleaner documentation.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
