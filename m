Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0166B0009
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 11:44:21 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l68so88601744wml.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 08:44:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y133si5761044wme.72.2016.03.02.08.44.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 08:44:19 -0800 (PST)
Subject: Re: [PATCH v4 1/2] mm: introduce page reference manipulation
 functions
References: <1456448282-897-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D71860.7050108@suse.cz>
Date: Wed, 2 Mar 2016 17:44:16 +0100
MIME-Version: 1.0
In-Reply-To: <1456448282-897-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/26/2016 01:58 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Success of CMA allocation largely depends on success of migration
> and key factor of it is page reference count. Until now, page reference
> is manipulated by direct calling atomic functions so we cannot follow up
> who and where manipulate it. Then, it is hard to find actual reason
> of CMA allocation failure. CMA allocation should be guaranteed to succeed
> so finding offending place is really important.
>
> In this patch, call sites where page reference is manipulated are converted
> to introduced wrapper function. This is preparation step to add tracepoint
> to each page reference manipulation function. With this facility, we can
> easily find reason of CMA allocation failure. There is no functional change
> in this patch.
>
> In addition, this patch also converts reference read sites. It will help
> a second step that renames page._count to something else and prevents later
> attempt to direct access to it (Suggested by Andrew).
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Even without Patch 2/2 this is a nice improvement.
Acked-by: Vlastimil Babka <vbabka@suse.cz>

Although somebody might be confused by page_ref_count() vs page_count(). 
Oh well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
