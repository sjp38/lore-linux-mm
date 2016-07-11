Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA6ED6B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 18:20:17 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id q2so82180135pap.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 15:20:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b6si114077pay.102.2016.07.11.15.20.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 15:20:17 -0700 (PDT)
Date: Mon, 11 Jul 2016 15:20:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, vmscan: Give up balancing node for high order
 allocations earlier
Message-Id: <20160711152015.e3be8be7702fb0ca4625040d@linux-foundation.org>
In-Reply-To: <00ed01d1d1c8$fcb12ff0$f6138fd0$@alibaba-inc.com>
References: <00ed01d1d1c8$fcb12ff0$f6138fd0$@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Mel Gorman' <mgorman@techsingularity.net>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 29 Jun 2016 13:42:12 +0800 "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:

> To avoid excessive reclaim, we give up rebalancing for high order 
> allocations right after reclaiming enough pages.

hm.  What are the observed runtime effects of this change?  Any testing
results?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
