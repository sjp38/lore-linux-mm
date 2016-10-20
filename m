Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9388C6B0253
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 09:34:00 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id 83so46538776vkd.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 06:34:00 -0700 (PDT)
Received: from mail-qk0-f196.google.com (mail-qk0-f196.google.com. [209.85.220.196])
        by mx.google.com with ESMTPS id i1si19450253vkb.15.2016.10.20.06.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 06:33:59 -0700 (PDT)
Received: by mail-qk0-f196.google.com with SMTP id v138so4555268qka.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 06:33:59 -0700 (PDT)
Date: Thu, 20 Oct 2016 15:33:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] fs/proc/meminfo: introduce Unaccounted statistic
Message-ID: <20161020133358.GN14609@dhcp22.suse.cz>
References: <20161020121149.9935-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020121149.9935-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On Thu 20-10-16 14:11:49, Vlastimil Babka wrote:
[...]
> Hi, I'm wondering if people would find this useful. If you think it is, and
> to not make performance worse, I could also make sure in proper submission
> that values are not read via global_page_state() multiple times etc...

I definitely find this information useful and hate to do the math all
the time but on the other hand this is quite fragile and I can imagine
we can easily forget to add something there and provide a misleading
information to the userspace. So I would be worried with a long term
maintainability of this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
