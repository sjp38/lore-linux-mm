Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6504B6B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 09:00:39 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so36235641lfc.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 06:00:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si4328378wjj.56.2016.04.27.06.00.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 06:00:38 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm, page_alloc: pull out side effects from
 free_pages_check
References: <5720A987.7060507@suse.cz>
 <1461758476-450-1-git-send-email-vbabka@suse.cz>
 <1461758476-450-2-git-send-email-vbabka@suse.cz>
 <20160427124136.GJ2858@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5720B7F4.80505@suse.cz>
Date: Wed, 27 Apr 2016 15:00:36 +0200
MIME-Version: 1.0
In-Reply-To: <20160427124136.GJ2858@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On 04/27/2016 02:41 PM, Mel Gorman wrote:
> On Wed, Apr 27, 2016 at 02:01:15PM +0200, Vlastimil Babka wrote:
>> Check without side-effects should be easier to maintain. It also removes the
>> duplicated cpupid and flags reset done in !DEBUG_VM variant of both
>> free_pcp_prepare() and then bulkfree_pcp_prepare(). Finally, it enables
>> the next patch.
>>
>
> Hmm, now the cpuid and flags reset is done in multiple places. While
> this is potentially faster, it goes against the comment "I don't like the
> duplicated code in free_pcp_prepare() from maintenance perspective".

After patch 3/3 it's done only in free_pages_prepare() which I think is 
not that bad, even though it's two places there. Tail pages are already 
special in that function. And I thought that the fact it was done twice 
in !DEBUG_VM free path was actually not intentional, but a consequence 
of the side-effect being unexpected. But it's close to bike-shedding 
area so I don't insist. Anyway, overal I like the code after patch 3/3 
better than before 2/3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
