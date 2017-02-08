Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28B196B0069
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 10:13:16 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id m98so147399092iod.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 07:13:16 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id j4si14989781iob.29.2017.02.08.07.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 07:13:15 -0800 (PST)
Date: Wed, 8 Feb 2017 09:13:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
In-Reply-To: <d3a1f708-efdd-98c3-9c26-dab600501679@suse.cz>
Message-ID: <alpine.DEB.2.20.1702080912560.3955@east.gentwo.org>
References: <20170203181008.24898-1-vbabka@suse.cz> <201702080139.e2GzXRQt%fengguang.wu@intel.com> <20170207133839.f6b1f1befe4468770991f5e0@linux-foundation.org> <d3a1f708-efdd-98c3-9c26-dab600501679@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Matthew Wilcox <willy@linux.intel.com>

On Wed, 8 Feb 2017, Vlastimil Babka wrote:

> I was going to implement Christoph's suggestion and export the whole structure
> in mm/slab.h, but gcc was complaining that I'm redefining it, until I created a
> typedef first. Is it worth the trouble? Below is how it would look like.

Looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
