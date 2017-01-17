Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20E476B025E
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:55:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so142186175pgb.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:55:55 -0800 (PST)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id x7si26289066plm.293.2017.01.17.14.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 14:55:54 -0800 (PST)
Received: by mail-pg0-x231.google.com with SMTP id 194so28040478pgd.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:55:54 -0800 (PST)
Date: Tue, 17 Jan 2017 14:55:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mm, page_alloc: do not report all nodes in
 show_mem
In-Reply-To: <20170117091543.25850-2-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1701171455360.142998@chino.kir.corp.google.com>
References: <20170117091543.25850-1-mhocko@kernel.org> <20170117091543.25850-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 17 Jan 2017, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> 599d0c954f91 ("mm, vmscan: move LRU lists to node") has added per numa
> node statistics to show_mem but it forgot to add skip_free_areas_node
> to fileter out nodes which are outside of the allocating task numa
> policy. Add this check to not pollute the output with the pointless
> information.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

s/fileter/filter/

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
