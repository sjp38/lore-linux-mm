Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABEE36B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 16:11:05 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so209999571pab.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 13:11:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g199si17476657pfb.195.2016.07.22.13.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 13:11:04 -0700 (PDT)
Date: Fri, 22 Jul 2016 13:11:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mem-hotplug: alloc new page from the next node if
 zone is MOVABLE_ZONE
Message-Id: <20160722131103.23c02a66d086df8f2ddae601@linux-foundation.org>
In-Reply-To: <57918BAC.8000008@huawei.com>
References: <57918BAC.8000008@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 22 Jul 2016 10:57:48 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> Memory offline could happen on both movable zone and non-movable zone.
> We can offline the whole node if the zone is movable zone, and if the
> zone is non-movable zone, we cannot offline the whole node, because
> some kernel memory can't be migrated.
> 
> So if we offline a node with movable zone, use prefer mempolicy to alloc
> new page from the next node instead of the current node or other remote
> nodes, because re-migrate is a waste of time and the distance of the
> remote nodes is often very large.
> 
> Also use GFP_HIGHUSER_MOVABLE to alloc new page if the zone is movable
> zone.

This conflicts pretty significantly with your "mem-hotplug: use
different mempolicy in alloc_migrate_target()".  Does it replace
"mem-hotplug: use different mempolicy in alloc_migrate_target()" and
your "mem-hotplug: use GFP_HIGHUSER_MOVABLE in,
alloc_migrate_target()", or what?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
