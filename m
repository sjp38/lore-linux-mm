Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id A82086B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 12:39:00 -0500 (EST)
Received: by lfs39 with SMTP id 39so17584318lfs.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 09:38:59 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id pd3si2261308lbb.196.2015.12.08.09.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 09:38:59 -0800 (PST)
Date: Tue, 8 Dec 2015 09:38:26 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V3][for-next] mm: add a new vector based madvise syscall
Message-ID: <20151208173825.GA1351950@devbig084.prn1.facebook.com>
References: <7c6ce0f1fe29fc22faf72134f4e2674da8d3d149.1449532062.git.shli@fb.com>
 <20151208061807.GO15533@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151208061807.GO15533@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>

On Tue, Dec 08, 2015 at 07:18:08AM +0100, Andi Kleen wrote:
> > +	if (behavior != MADV_DONTNEED && behavior != MADV_FREE)
> > +		return -EINVAL;
> 
> This limitations is kind of lame and makes it a special purpose hack.
> 
> It will also cause backwards compatibility issues if it needs
> to be extended later.
> 
> How hard would it be to support all of madvise vectored?
> 
> That would also give much cleaner documentation.

Ok, I'll add other behavior. Reducing syscall and mmap_sem locking is a
win for other madvise.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
