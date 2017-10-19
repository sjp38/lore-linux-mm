Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4B56B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:24:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k4so3228917wmc.20
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:24:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o22si11108539wra.508.2017.10.19.02.24.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 02:24:52 -0700 (PDT)
Subject: Re: [PATCH 5/8] mm, pagevec: Remove cold parameter for pagevecs
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-6-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e049fbe6-f5bc-80c2-25c6-c2ee0cb91728@suse.cz>
Date: Thu, 19 Oct 2017 11:24:51 +0200
MIME-Version: 1.0
In-Reply-To: <20171018075952.10627-6-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On 10/18/2017 09:59 AM, Mel Gorman wrote:
> Every pagevec_init user claims the pages being released are false even in
> cases where it is unlikely the pages are hot. As no one cares about the
> hotness of pages being released to the allocator, just ditch the parameter.
> 
> No performance impact is expected as the overhead is marginal. The parameter
> is removed simply because it is a bit stupid to have a useless parameter
> copied everywhere.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
