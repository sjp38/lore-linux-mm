Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6957C280257
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:11:41 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so88311524igc.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:11:41 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id q10si1459326ioi.93.2015.07.14.11.11.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 11:11:40 -0700 (PDT)
Date: Tue, 14 Jul 2015 13:11:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm/slub: fix slab double-free in case of duplicate
 sysfs filename
In-Reply-To: <20150714131704.21442.17939.stgit@buzz>
Message-ID: <alpine.DEB.2.11.1507141311150.28065@east.gentwo.org>
References: <20150714131704.21442.17939.stgit@buzz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org


> last reference of kmem-cache kobject and frees it. Kmem cache will be
> freed second time at error path in kmem_cache_create().

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
