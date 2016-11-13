Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E72B26B0038
	for <linux-mm@kvack.org>; Sun, 13 Nov 2016 12:27:05 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id rf5so70392789pab.3
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 09:27:05 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id e13si19125730pgf.287.2016.11.13.09.27.04
        for <linux-mm@kvack.org>;
        Sun, 13 Nov 2016 09:27:05 -0800 (PST)
Date: Sun, 13 Nov 2016 12:27:03 -0500 (EST)
Message-Id: <20161113.122703.2122997256308305867.davem@davemloft.net>
Subject: Re: [mm PATCH v3 17/23] arch/sparc: Add option to skip DMA sync as
 a part of map and unmap
From: David Miller <davem@davemloft.net>
In-Reply-To: <20161110113544.76501.40008.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
	<20161110113544.76501.40008.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@intel.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, sparclinux@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Nov 2016 06:35:45 -0500

> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> via a sync_for_cpu or sync_for_device call.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
