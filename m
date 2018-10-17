Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9F636B0266
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 05:51:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 31-v6so16380325edr.19
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:51:34 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id v11-v6si6942614eju.193.2018.10.17.02.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 02:51:33 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id E80E11C19A6
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 10:51:32 +0100 (IST)
Date: Wed, 17 Oct 2018 10:51:31 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC v4 PATCH 1/5] mm/page_alloc: use helper functions to
 add/remove a page to/from buddy
Message-ID: <20181017095131.GI5819@techsingularity.net>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-2-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181017063330.15384-2-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Oct 17, 2018 at 02:33:26PM +0800, Aaron Lu wrote:
> There are multiple places that add/remove a page into/from buddy,
> introduce helper functions for them.
> 
> This also makes it easier to add code when a page is added/removed
> to/from buddy.
> 
> No functionality change.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
