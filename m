Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 674BC6B0397
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 21:39:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q25so7683724pfg.6
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 18:39:21 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id q81si11285910pfd.218.2017.04.11.18.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 18:39:20 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id g2so2382927pge.2
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 18:39:20 -0700 (PDT)
Date: Wed, 12 Apr 2017 10:39:13 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170412013911.GB8448@js1304-desktop>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Tue, Apr 11, 2017 at 12:17:13PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Changed from v6
> o Rebase on next-20170405
> o Add a fix for lowmem mapping on ARM (last patch)

Hello, Russell and Will.

In this 7th patchset, I newly added a patch for ARM.
Could you review it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
