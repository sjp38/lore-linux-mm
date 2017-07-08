Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 985B8440843
	for <linux-mm@kvack.org>; Sat,  8 Jul 2017 15:47:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so15326505wry.4
        for <linux-mm@kvack.org>; Sat, 08 Jul 2017 12:47:42 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id k5si5753940edb.186.2017.07.08.12.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Jul 2017 12:47:41 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 8B97F1C2227
	for <linux-mm@kvack.org>; Sat,  8 Jul 2017 20:47:40 +0100 (IST)
Date: Sat, 8 Jul 2017 20:47:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/page_alloc.c: improve allocation fast path
Message-ID: <20170708194739.chisy47mz4c2c2ye@techsingularity.net>
References: <1499477319-1395-1-git-send-email-zbestahu@aliyun.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1499477319-1395-1-git-send-email-zbestahu@aliyun.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zbestahu@aliyun.com
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, hannes@cmpxchg.org, minchan@kernel.org, linux-mm@kvack.org, Yue Hu <huyue2@coolpad.com>

On Sat, Jul 08, 2017 at 09:28:39AM +0800, zbestahu@aliyun.com wrote:
> From: Yue Hu <huyue2@coolpad.com>
> 
> We currently is taking time to check if the watermark is safe when
> alloc_flags is setting with ALLOC_NO_WATERMARK in slowpath, the check
> to alloc_flags is faster check which should be first check option
> compared to the slow check of watermark, it could benefit to urgency
> allocation request in slowpath, it also almost has no effect for
> allocation with successful watermark check.
> 
> Signed-off-by: Yue Hu <huyue2@coolpad.com>

NAK. Was this measured as being a benefit to anything?

ALLOC_NO_WATERMARKS is rare so it's in the slow path. Even though the
watermark check is redundent when watermarks should be ignored, your patch
adds a branch that is rarely true to the common case. The comment you move
even gives a hint as to why it's located there!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
