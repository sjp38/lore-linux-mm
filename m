Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 105ED6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:05:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y134so54349034pfg.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 12:05:21 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id v27si1845028pfj.178.2016.07.19.12.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 12:05:20 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id iw10so9617159pac.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 12:05:20 -0700 (PDT)
Date: Tue, 19 Jul 2016 12:05:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in,
 alloc_migrate_target()
In-Reply-To: <578DD44F.3040507@huawei.com>
Message-ID: <alpine.DEB.2.10.1607191204320.52203@chino.kir.corp.google.com>
References: <57884EAA.9030603@huawei.com> <20160718055150.GF9460@js1304-P5Q-DELUXE> <578C8C8A.8000007@huawei.com> <7ce4a7ac-07aa-6a81-48c2-91c4a9355778@suse.cz> <578C93CF.50509@huawei.com> <20160719065042.GC17479@js1304-P5Q-DELUXE>
 <578DD44F.3040507@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 19 Jul 2016, Xishi Qiu wrote:

> Memory offline could happen on both movable zone and non-movable zone, and we
> can offline the whole node if the zone is movable_zone(the node only has one
> movable_zone), and if the zone is normal_zone, we cannot offline the whole node,
> because some kernel memory can't be migrated.
> 
> So how about change alloc_migrate_target() to alloc memory from the next node
> with GFP_HIGHUSER_MOVABLE, if the offline zone is movable_zone.
> 

I think sharing alloc_migrate_target as a migration callback may not be 
worth it; CMA and memory offline are distinct usecases and probably 
deserve their own callbacks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
