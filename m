Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B1BD86B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 02:19:23 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b2so8618883pgc.6
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 23:19:23 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id i3si460679plk.133.2017.02.21.23.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 23:19:22 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id s67so868524pgb.1
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 23:19:22 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 22 Feb 2017 18:19:15 +1100
Subject: Re: [HMM v17 00/14] HMM (Heterogeneous Memory Management) v17
Message-ID: <20170222071915.GE9967@balbir.ozlabs.ibm.com>
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

On Fri, Jan 27, 2017 at 05:52:07PM -0500, Jerome Glisse wrote:
> Cliff note: HMM offers 2 things (each standing on its own). First
> it allows to use device memory transparently inside any process
> without any modifications to process program code. Second it allows
> to mirror process address space on a device.
> 
> Change since v16:
>   - move HMM unaddressable device memory to its own radix tree and
>     thus find_dev_pagemap() will no longer return HMM dev_pagemap
>   - rename HMM migration helper (drop the prefix) and make them
>     completely independent of HMM
> 
>     Migration can now be use to implement thing like multi-threaded
>     copy or make use of specific memory allocator for destination
>     memory.
> 
> Work is under way to use this feature inside nouveau (the upstream
> open source driver for NVidia GPU) either 411 or 4.12 timeframe.
> But this patchset have been otherwise tested with the close source
> driver for NVidia GPU and thus we are confident it works and allow
> to use the hardware for seamless interaction between CPU and GPU
> in common address space of a process.
> 
> I also discussed the features with other company and i am confident
> it can be use on other, yet, unrelease hardware.
> 
> Please condiser applying for 4.11
>

Andrew, do we expect to get this in 4.11/4.12? Just curious.

Balbir Singh. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
