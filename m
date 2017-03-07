Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C96256B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 12:45:28 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v66so3112881wrc.4
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 09:45:28 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v25si856399wra.330.2017.03.07.09.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 09:45:27 -0800 (PST)
Date: Tue, 7 Mar 2017 12:39:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Do not use double negation for testing page flags
Message-ID: <20170307173934.GA22291@cmpxchg.org>
References: <1488868597-32222-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488868597-32222-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Vlastimil Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Chen Gang <gang.chen.5i5j@gmail.com>

On Tue, Mar 07, 2017 at 03:36:37PM +0900, Minchan Kim wrote:
> With the discussion[1], I found it seems there are every PageFlags
> functions return bool at this moment so we don't need double
> negation any more.
> Although it's not a problem to keep it, it makes future users
> confused to use dobule negation for them, too.
> 
> Remove such possibility.
> 
> [1] https://marc.info/?l=linux-kernel&m=148881578820434
> 
> Frankly sepaking, I like every PageFlags return bool instead of int.
> It will make it clear. AFAIR, Chen Gang had tried it but don't know
> why it was not merged at that time.
> 
> http://lkml.kernel.org/r/1469336184-1904-1-git-send-email-chengang@emindsoft.com.cn
> 
> Cc: Vlastimil Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Chen Gang <gang.chen.5i5j@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
