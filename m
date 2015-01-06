Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id B97C46B00B2
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 04:05:42 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w61so9322499wes.29
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 01:05:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a3si77316353wje.161.2015.01.06.01.05.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 01:05:41 -0800 (PST)
Message-ID: <54ABA563.1040103@suse.cz>
Date: Tue, 06 Jan 2015 10:05:39 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/compaction: enhance trace output to know more
 about compaction internals
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/03/2014 08:52 AM, Joonsoo Kim wrote:
> It'd be useful to know where the both scanner is start. And, it also be
> useful to know current range where compaction work. It will help to find
> odd behaviour or problem on compaction.

Overall it looks good, just two questions:
1) Why change the pfn output to hexadecimal with different printf layout and
change the variable names and? Is it that better to warrant people having to
potentially modify their scripts parsing the old output?
2) Would it be useful to also print in the mm_compaction_isolate_template based
tracepoints, pfn of where the particular scanner left off a block prematurely?
It doesn't always match start_pfn + nr_scanned.

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
