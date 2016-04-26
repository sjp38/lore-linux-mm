Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0E5F6B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:29:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so9797568wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:29:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lv2si21849299wjb.230.2016.04.26.04.29.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:29:43 -0700 (PDT)
Subject: Re: [PATCH 07/28] mm, page_alloc: Avoid unnecessary zone lookups
 during pageblock operations
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-8-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F5125.6050502@suse.cz>
Date: Tue, 26 Apr 2016 13:29:41 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-8-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:58 AM, Mel Gorman wrote:
> Pageblocks have an associated bitmap to store migrate types and whether
> the pageblock should be skipped during compaction. The bitmap may be
> associated with a memory section or a zone but the zone is looked up
> unconditionally. The compiler should optimise this away automatically so
> this is a cosmetic patch only in many cases.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
