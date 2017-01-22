Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A94C26B0266
	for <linux-mm@kvack.org>; Sat, 21 Jan 2017 23:45:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 14so154525083pgg.4
        for <linux-mm@kvack.org>; Sat, 21 Jan 2017 20:45:53 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id f12si11583656pgn.136.2017.01.21.20.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Jan 2017 20:45:52 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id f144so7906054pfa.2
        for <linux-mm@kvack.org>; Sat, 21 Jan 2017 20:45:52 -0800 (PST)
Date: Sun, 22 Jan 2017 13:45:18 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170122044518.GB7057@tigerII.localdomain>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On (01/22/17 10:58), zhouxianrong wrote:
> 1. memset is just set a int value but i want to set a long value.

ah... ok. because you union it with the handle.

> 2. using clear_page rather than memset MAYBE due to in arm64 arch
>    it is a 64-bytes operations.

clear_page() basically does memset(), which is quite well optimized.
except for arm64, yes.


> 6.6.4. Data Cache Zero
> 
> The ARMv8-A architecture introduces a Data Cache Zero by Virtual Address (DC ZVA) instruction. This enables a block of 64
> bytes in memory, aligned to 64 bytes in size, to be set to zero. If the DC ZVA instruction misses in the cache, it clears main
> memory, without causing an L1 or L2 cache allocation.
> 
> but i only consider the arm64 arch, other archs need to be reviewed.

thaks for the reply.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
