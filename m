Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 932E68E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 06:59:50 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so999405edm.18
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:59:50 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i25si2382772edb.334.2019.01.15.03.59.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 03:59:49 -0800 (PST)
Subject: Re: [PATCH 05/25] mm, compaction: Rename map_pages to split_map_pages
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-6-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e51dba33-ce95-eccd-8223-f383bd71f4cd@suse.cz>
Date: Tue, 15 Jan 2019 12:59:48 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-6-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:49 PM, Mel Gorman wrote:
> It's non-obvious that high-order free pages are split into order-0 pages
> from the function name. Fix it.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
