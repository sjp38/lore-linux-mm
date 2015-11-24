Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 931DA6B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 09:57:09 -0500 (EST)
Received: by wmec201 with SMTP id c201so30279907wme.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:57:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1si27249200wmw.37.2015.11.24.06.57.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 06:57:08 -0800 (PST)
Subject: Re: [PATCH 1/3] mm/page_isolation: return last tested pfn rather than
 failure indicator
References: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56547ABE.8020001@suse.cz>
Date: Tue, 24 Nov 2015 15:57:02 +0100
MIME-Version: 1.0
In-Reply-To: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/13/2015 03:23 AM, Joonsoo Kim wrote:
> This is preparation step to report test failed pfn in new tracepoint
> to analyze cma allocation failure problem. There is no functional change
> in this patch.
>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
