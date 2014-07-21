Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E94FC6B0036
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 22:33:46 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so8953984pab.29
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 19:33:46 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id gj8si12735557pac.127.2014.07.20.19.33.44
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 19:33:45 -0700 (PDT)
Message-ID: <53CC7C05.3060703@lge.com>
Date: Mon, 21 Jul 2014 11:33:41 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [PATCHv2] CMA/HOTPLUG: clear buffer-head lru before page migration
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, =?EUC-KR?B?J7Howdi89ic=?= <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?EUC-KR?B?wMywx8ij?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

I removed checking migratetype of v1: https://lkml.org/lkml/2014/7/18/82.
Thanks a lot.


---------------------------- 8< ------------------------------
