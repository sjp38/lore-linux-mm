Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C4E5F6B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 09:57:21 -0500 (EST)
Received: by wmvv187 with SMTP id v187so213487427wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:57:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vl1si27392102wjc.33.2015.11.24.06.57.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 06:57:20 -0800 (PST)
Subject: Re: [PATCH 2/3] mm/page_isolation: add new tracepoint,
 test_pages_isolated
References: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447381428-12445-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56547ACF.5050706@suse.cz>
Date: Tue, 24 Nov 2015 15:57:19 +0100
MIME-Version: 1.0
In-Reply-To: <1447381428-12445-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/13/2015 03:23 AM, Joonsoo Kim wrote:
> cma allocation should be guranteeded to succeed, but, sometimes,
> it could be failed in current implementation. To track down
> the problem, we need to know which page is problematic and
> this new tracepoint will report it.
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
