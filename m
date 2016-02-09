Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0066B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 12:58:36 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id 128so206990530wmz.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 09:58:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si50591518wjx.95.2016.02.09.09.58.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 09:58:35 -0800 (PST)
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
 <CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56BA28C8.3060903@suse.cz>
Date: Tue, 9 Feb 2016 18:58:32 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/05/2016 05:11 PM, Joonsoo Kim wrote:
> Yeah, it seems wrong to me. :)
> Here goes fix.

Doesn't apply for me, even after fixing the most obvious line wraps.
Seems like the version in mmotm is still your original patch and
Andrew's hotfix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
