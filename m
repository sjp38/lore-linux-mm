Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8E86B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 00:40:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 81so34491735pgh.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:40:28 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id g13si4053033pgf.56.2017.03.15.21.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 21:40:27 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id y17so4574706pgh.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:40:27 -0700 (PDT)
Date: Thu, 16 Mar 2017 13:40:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 10/10] mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
Message-ID: <20170316044023.GA2597@jagdpanzerIV.localdomain>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
 <1489555493-14659-11-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489555493-14659-11-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

Hello,


On (03/15/17 14:24), Minchan Kim wrote:
> There is no user for it. Remove it.
> 

there is one.

mm/rmap.c

try_to_unmap_one()
...
	if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
		WARN_ON_ONCE(1);
		ret = SWAP_FAIL;
		page_vma_mapped_walk_done(&pvmw);
		break;
	}

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
