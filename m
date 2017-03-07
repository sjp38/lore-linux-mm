Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D11226B038D
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 09:20:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y51so1033383wry.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:20:55 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 63si205707wrp.137.2017.03.07.06.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 06:20:54 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id v190so1231951wme.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:20:54 -0800 (PST)
Date: Tue, 7 Mar 2017 17:20:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 03/11] mm: remove SWAP_DIRTY in ttu
Message-ID: <20170307142051.GC2779@node.shutemov.name>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488436765-32350-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shli@kernel.org>

On Thu, Mar 02, 2017 at 03:39:17PM +0900, Minchan Kim wrote:
> If we found lazyfree page is dirty, ttuo can just SetPageSwapBakced
> in there like PG_mlocked page and just return with SWAP_FAIL which
> is very natural because the page is not swappable right now so that
> vmscan can activate it. There is no point to introduce new return
> value SWAP_DIRTY in ttu at the moment.
> 
> Cc: Shaohua Li <shli@kernel.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
