Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1942280258
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 17:03:54 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so374940447pfx.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:03:54 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id e72si32016815pfd.125.2016.12.22.14.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 14:03:54 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id d2so41464111pfd.0
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:03:54 -0800 (PST)
Date: Thu, 22 Dec 2016 14:03:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mm: add new mmgrab() helper
In-Reply-To: <20161218123229.22952-1-vegard.nossum@oracle.com>
Message-ID: <alpine.DEB.2.10.1612221403340.108886@chino.kir.corp.google.com>
References: <20161218123229.22952-1-vegard.nossum@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Sun, 18 Dec 2016, Vegard Nossum wrote:

> Apart from adding the helper function itself, the rest of the kernel is
> converted mechanically using:
> 
>   git grep -l 'atomic_inc.*mm_count' | xargs sed -i 's/atomic_inc(&\(.*\)->mm_count);/mmgrab\(\1\);/'
>   git grep -l 'atomic_inc.*mm_count' | xargs sed -i 's/atomic_inc(&\(.*\)\.mm_count);/mmgrab\(\&\1\);/'
> 
> This is needed for a later patch that hooks into the helper, but might be
> a worthwhile cleanup on its own.
> 
> (Michal Hocko provided most of the kerneldoc comment.)
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Acked-by: David Rientjes <rientjes@google.com>

for the series

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
