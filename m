Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC2D6B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 03:34:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so10234734wml.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 00:34:15 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id p71si1917333wmf.51.2016.08.09.00.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 00:34:14 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id D65B01C1A87
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 08:34:13 +0100 (IST)
Date: Tue, 9 Aug 2016 08:34:12 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm/page_alloc: recalculate some of node threshold
 when on/offline memory
Message-ID: <20160809073412.GB8119@techsingularity.net>
References: <1470724248-26780-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470724248-26780-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1470724248-26780-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, Aug 09, 2016 at 03:30:48PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Some of node threshold depends on number of managed pages in the node.
> When memory is going on/offline, it can be changed and we need to
> adjust them.
> 
> This patch add recalculation to appropriate places and clean-up
> related function for better maintanance.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
