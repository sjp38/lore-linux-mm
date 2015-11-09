Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D27636B0038
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 17:55:22 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so188704585pac.3
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 14:55:22 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id yt1si450566pab.45.2015.11.09.14.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 14:55:22 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so213056877pab.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 14:55:21 -0800 (PST)
Date: Mon, 9 Nov 2015 14:55:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm/page_isolation: return last tested pfn rather
 than failure indicator
In-Reply-To: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1511091455090.20636@chino.kir.corp.google.com>
References: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 9 Nov 2015, Joonsoo Kim wrote:

> This is preparation step to report test failed pfn in new tracepoint
> to analyze cma allocation failure problem. There is no functional change
> in this patch.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
