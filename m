Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EEC96B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:47:28 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j18so82026948ioe.3
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:47:28 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id w139si9302487iod.132.2017.02.06.06.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:47:27 -0800 (PST)
Date: Mon, 6 Feb 2017 08:47:21 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
In-Reply-To: <20170203181008.24898-1-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.20.1702060847050.27661@east.gentwo.org>
References: <20170203181008.24898-1-vbabka@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
