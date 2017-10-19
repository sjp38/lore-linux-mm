Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 197E26B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:26:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l10so3240997wmg.5
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:26:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w18si7417604wra.224.2017.10.19.02.26.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 02:26:56 -0700 (PDT)
Subject: Re: [PATCH 6/8] mm: Remove cold parameter for release_pages
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-7-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <72f644cf-f891-e3a6-98ed-ed3a25c44ce2@suse.cz>
Date: Thu, 19 Oct 2017 11:26:55 +0200
MIME-Version: 1.0
In-Reply-To: <20171018075952.10627-7-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On 10/18/2017 09:59 AM, Mel Gorman wrote:
> All callers of release_pages claim the pages being released are cache hot.
> As no one cares about the hotness of pages being released to the allocator,
> just ditch the parameter.
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
