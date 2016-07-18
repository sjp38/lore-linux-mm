Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE0E56B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:47:45 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hh10so303835385pac.3
        for <linux-mm@kvack.org>; Sun, 17 Jul 2016 22:47:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id gk9si24896747pac.182.2016.07.17.22.47.44
        for <linux-mm@kvack.org>;
        Sun, 17 Jul 2016 22:47:45 -0700 (PDT)
Date: Mon, 18 Jul 2016 14:51:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in,
 alloc_migrate_target()
Message-ID: <20160718055150.GF9460@js1304-P5Q-DELUXE>
References: <57884EAA.9030603@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57884EAA.9030603@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 10:47:06AM +0800, Xishi Qiu wrote:
> alloc_migrate_target() is called from migrate_pages(), and the page
> is always from user space, so we can add __GFP_HIGHMEM directly.

No, all migratable pages are not from user space. For example,
blockdev file cache has __GFP_MOVABLE and migratable but it has no
__GFP_HIGHMEM and __GFP_USER.

And, zram's memory isn't GFP_HIGHUSER_MOVABLE but has __GFP_MOVABLE.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
