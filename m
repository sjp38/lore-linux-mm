Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59EAA6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 04:15:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id t30so4110580wra.7
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 01:15:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p90si4462191wrb.39.2017.06.08.01.15.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 01:15:19 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm, memory_hotplug: simplify empty node mask handling
 in new_node_page
References: <20170608074553.22152-1-mhocko@kernel.org>
 <20170608074553.22152-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f8f22a22-355d-44d9-69d3-492ea9e24c8f@suse.cz>
Date: Thu, 8 Jun 2017 10:15:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170608074553.22152-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/08/2017 09:45 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> new_node_page tries to allocate the target page on a different NUMA node
> than the source page. This makes sense in most cases during the hotplug
> because we are likely to offline the whole numa node. But there are
> cases where there are no other nodes to fallback (e.g. when offlining
> parts of the only existing node) and we have to fallback to allocating
> from the source node. The current code does that but it can be
> simplified by checking the nmask and updating it before we even try to
> allocate rather than special casing it.
> 
> This patch shouldn't introduce any functional change.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
