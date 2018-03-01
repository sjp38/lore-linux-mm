Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAA26B0006
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 07:11:15 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id m19so5637641iob.13
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 04:11:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 124sor2303198iow.118.2018.03.01.04.11.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 04:11:14 -0800 (PST)
Date: Thu, 1 Mar 2018 04:11:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 1/3] mm/free_pcppages_bulk: update pcp->count inside
In-Reply-To: <20180301062845.26038-2-aaron.lu@intel.com>
Message-ID: <alpine.DEB.2.20.1803010410580.91729@chino.kir.corp.google.com>
References: <20180301062845.26038-1-aaron.lu@intel.com> <20180301062845.26038-2-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Thu, 1 Mar 2018, Aaron Lu wrote:

> Matthew Wilcox found that all callers of free_pcppages_bulk() currently
> update pcp->count immediately after so it's natural to do it inside
> free_pcppages_bulk().
> 
> No functionality or performance change is expected from this patch.
> 
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
