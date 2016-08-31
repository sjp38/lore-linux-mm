Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0D86B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:35:13 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id 18so9557588ybc.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:35:13 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 77si1691244pft.11.2016.08.31.14.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 14:35:12 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH -v2] mm: Don't use radix tree writeback tags for pages in swap cache
References: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
	<20160831091459.GY8119@techsingularity.net>
	<87oa49m0hn.fsf@yhuang-mobile.sh.intel.com>
	<20160831153908.GA8119@techsingularity.net>
Date: Wed, 31 Aug 2016 14:35:11 -0700
In-Reply-To: <20160831153908.GA8119@techsingularity.net> (Mel Gorman's message
	of "Wed, 31 Aug 2016 16:39:08 +0100")
Message-ID: <87vaygzkog.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Mel Gorman <mgorman@techsingularity.net> writes:
>
> __GFP_BITS_SHIFT + 5 (AS_NO_WRITEBACK_TAGS) = 31
>
> mapping->flags is a combination of AS and GFP flags so increasing
> __GFP_BITS_SHIFT overflows mapping->flags on 32-bit as gfp_t is an
> unsigned int.

Couldn't we just split mapping->flags into two fields?
I'm sure more GFP bits will be needed eventually.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
