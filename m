Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A60A06B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:56:39 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q20so82463770ioi.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:56:39 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [69.252.207.42])
        by mx.google.com with ESMTPS id q184si9308823iof.74.2017.02.06.06.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:56:39 -0800 (PST)
Date: Mon, 6 Feb 2017 08:55:37 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
In-Reply-To: <20170206145238.GI2267@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1702060854330.27871@east.gentwo.org>
References: <20170203181008.24898-1-vbabka@suse.cz> <20170206145238.GI2267@bombadil.infradead.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On Mon, 6 Feb 2017, Matthew Wilcox wrote:

> Could we lose the 'get_' from the front?  I think 'kmalloc_cache_name()' is
> just as informative.

Hmmm.. Expose the static array in mm/slab.h instead? There may be other
cases in which the allocator specific code may need that information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
