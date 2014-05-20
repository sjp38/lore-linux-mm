Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA0F6B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 01:57:51 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so6769620pab.33
        for <linux-mm@kvack.org>; Mon, 19 May 2014 22:57:50 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ay4si274860pbc.122.2014.05.19.22.57.48
        for <linux-mm@kvack.org>;
        Mon, 19 May 2014 22:57:50 -0700 (PDT)
Message-ID: <537AEEDB.2000001@lge.com>
Date: Tue, 20 May 2014 14:57:47 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [RFC PATCH] arm: dma-mapping: fallback allocation for cma failure
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?EUC-KR?B?J7Howdi89ic=?= <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>
Cc: =?EUC-KR?B?wMywx8ij?= <gunho.lee@lge.com>


Thanks for your advise, Michal Nazarewicz.

Having discuss with Joonsoo, I'm adding fallback allocation after __alloc_from_contiguous().
The fallback allocation works if CMA kernel options is turned on but CMA size is zero.

--------------------- 8< ------------------------
