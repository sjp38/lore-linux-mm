Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDC99003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 03:04:25 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so14630177wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 00:04:24 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id fz8si13196585wjb.67.2015.07.24.00.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 00:04:24 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so14641659wib.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 00:04:23 -0700 (PDT)
Date: Fri, 24 Jul 2015 09:04:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add resched points to
 remap_pmd_range/ioremap_pmd_range
Message-ID: <20150724070420.GF4103@dhcp22.suse.cz>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Spencer Baugh <sbaugh@catern.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Joern Engel <joern@purestorage.com>, Spencer Baugh <Spencer.baugh@purestorage.com>

On Thu 23-07-15 14:54:33, Spencer Baugh wrote:
> From: Joern Engel <joern@logfs.org>
> 
> Mapping large memory spaces can be slow and prevent high-priority
> realtime threads from preempting lower-priority threads for a long time.

How can a lower priority task block the high priority one? Do you have
preemption disabled?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
