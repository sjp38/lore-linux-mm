Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AAC236B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 17:51:22 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so112806597pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:51:22 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ip2si30181232pbd.176.2015.11.13.14.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 14:51:22 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so113248249pab.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:51:21 -0800 (PST)
Date: Fri, 13 Nov 2015 14:51:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm/page_isolation: add new tracepoint,
 test_pages_isolated
In-Reply-To: <1447381428-12445-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1511131451040.6173@chino.kir.corp.google.com>
References: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com> <1447381428-12445-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 13 Nov 2015, Joonsoo Kim wrote:

> cma allocation should be guranteeded to succeed, but, sometimes,
> it could be failed in current implementation. To track down
> the problem, we need to know which page is problematic and
> this new tracepoint will report it.
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for generalizing this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
