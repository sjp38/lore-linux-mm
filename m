Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DB4296B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 13:56:59 -0500 (EST)
Received: by pasz6 with SMTP id z6so39722118pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:56:59 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pa7si14241382pac.231.2015.11.11.10.56.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 10:56:59 -0800 (PST)
Date: Wed, 11 Nov 2015 21:56:48 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
Message-ID: <20151111185648.GY31308@esperanza>
References: <20151109181604.8231.22983.stgit@firesoul>
 <20151109181703.8231.66384.stgit@firesoul>
 <20151109191335.GM31308@esperanza>
 <20151109212522.6b38988c@redhat.com>
 <20151110084633.GT31308@esperanza>
 <20151110165534.6154082e@redhat.com>
 <20151110183246.GV31308@esperanza>
 <20151111162820.49fa8350@redhat.com>
 <20151111193059.5a9f5283@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151111193059.5a9f5283@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Wed, Nov 11, 2015 at 07:30:59PM +0100, Jesper Dangaard Brouer wrote:
...
> The problem was related to CONFIG_KMEMCHECK.  It was causing the system
> to not boot (I have not look into why yet, don't have full console
> output, but I can see it complains about PCI and ACPI init and then
> dies in x86_perf_event_update+0x15, thus it could be system/HW specific).

AFAIK kmemcheck is rarely used nowadays, because kasan does practically
the same and does it better, so failures are expected.

> 
> I'm now running with CONFIG_DEBUG_KMEMLEAK, and is running tests with

kmemleak must be OK. Personally I use it quite often.

> exhausting memory.  And it works, e.g. when the alloc fails and @object
> becomes NULL.

Cool.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
