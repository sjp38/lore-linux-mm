Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE69D8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 06:43:36 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so1013973edr.7
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:43:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n20-v6si1857346ejc.171.2019.01.15.03.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 03:43:35 -0800 (PST)
Subject: Re: [PATCH 04/25] mm, compaction: Remove unnecessary zone parameter
 in some instances
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-5-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d42cc468-e3ac-35c0-74d8-17ccb98407da@suse.cz>
Date: Tue, 15 Jan 2019 12:43:33 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-5-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:49 PM, Mel Gorman wrote:
> A zone parameter is passed into a number of top-level compaction functions
> despite the fact that it's already in cache_control. This is harmless but

                                        ^ compact_control

> it did need an audit to check if zone actually ever changes meaningfully.

Tried changing the field to "struct zone * const zone;" and it only
flagged compact_node() and kcompactd_do_work() which look ok.

> This patches removes the parameter in a number of top-level functions. The
> change could be much deeper but this was enough to briefly clarify the
> flow.
> 
> No functional change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
