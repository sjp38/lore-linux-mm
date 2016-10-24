Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 886BE6B026A
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:27:33 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id xx10so2769983pac.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:27:33 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id r17si16738850pgh.127.2016.10.24.11.27.32
        for <linux-mm@kvack.org>;
        Mon, 24 Oct 2016 11:27:32 -0700 (PDT)
Date: Mon, 24 Oct 2016 14:27:30 -0400 (EDT)
Message-Id: <20161024.142730.1316656811538193943.davem@davemloft.net>
Subject: Re: [net-next PATCH RFC 19/26] arch/sparc: Add option to skip DMA
 sync as a part of map and unmap
From: David Miller <davem@davemloft.net>
In-Reply-To: <20161024120607.16276.5989.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
	<20161024120607.16276.5989.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@intel.com
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, brouer@redhat.com

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:06:07 -0400

> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> via a sync_for_cpu or sync_for_device call.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: sparclinux@vger.kernel.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

This is fine for avoiding the flush for performance reasons, but the
chip isn't going to write anything back unless the device wrote into
the area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
