Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CC8776B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 21:29:23 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so4456213pad.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 18:29:23 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id cy1si1218875pad.200.2015.09.16.18.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 18:29:23 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so4455972pad.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 18:29:22 -0700 (PDT)
Date: Thu, 17 Sep 2015 10:30:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/2] prepare zbud to be used by zram as underlying
 allocator
Message-ID: <20150917013007.GB421@swordfish>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: ddstreet@ieee.org, akpm@linux-foundation.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (09/16/15 13:48), Vitaly Wool wrote:
> as a follow-up to my previous patchset, I decided to first prepare
> zbud/zpool related patches and then have some testing rounds and
> performance measurements for zram running over both, and come up
> with improved/verified zram/zpool patches then.

Hi,

just a side note,
I'm afraid this is not how it works. numbers go first, to justify
the patch set.

	-ss

>
> So for now, here comes the zbud/zpool part.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
