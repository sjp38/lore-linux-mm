Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7F82808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 11:21:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u12so27547910pgo.4
        for <linux-mm@kvack.org>; Wed, 10 May 2017 08:21:02 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id 3si3236507pfe.330.2017.05.10.08.21.01
        for <linux-mm@kvack.org>;
        Wed, 10 May 2017 08:21:01 -0700 (PDT)
Date: Wed, 10 May 2017 11:20:59 -0400 (EDT)
Message-Id: <20170510.112059.169845404310247896.davem@davemloft.net>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
From: David Miller <davem@davemloft.net>
In-Reply-To: <ab667486-54a0-a36e-6797-b5f7b83c10f7@oracle.com>
References: <3f5f1416-aa91-a2ff-cc89-b97fcaa3e4db@oracle.com>
	<20170510145726.GM31466@dhcp22.suse.cz>
	<ab667486-54a0-a36e-6797-b5f7b83c10f7@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com

From: Pasha Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 10 May 2017 11:01:40 -0400

> Perhaps you are right, and I will measure on x86. But, I suspect hit
> can become unacceptable on some platfoms: there is an overhead of
> calling a function, even if it is leaf-optimized, and there is an
> overhead in memset() to check for alignments of size and address,
> types of setting (zeroing vs. non-zeroing), etc., that adds up
> quickly.

Another source of overhead on the sparc64 side is that we much
do memory barriers around the block initializiing stores.  So
batching calls to memset() amortize that as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
