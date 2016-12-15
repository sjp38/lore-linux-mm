Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98FD76B0253
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 14:11:53 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id y124so72290793iof.4
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:11:53 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id y66si3135014iof.141.2016.12.15.11.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 11:11:53 -0800 (PST)
Date: Thu, 15 Dec 2016 13:11:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm, slab: make sure that KMALLOC_MAX_SIZE will fit
 into MAX_ORDER
In-Reply-To: <20161215164722.21586-3-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.20.1612151311220.23619@east.gentwo.org>
References: <20161215164722.21586-1-mhocko@kernel.org> <20161215164722.21586-3-mhocko@kernel.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Thu, 15 Dec 2016, Michal Hocko wrote:

> (see __alloc_pages_slowpath). The same applies to the SLOB allocator
> which allows even larger sizes. Make sure that they are capped properly
> and never request more than MAX_ORDER order.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
