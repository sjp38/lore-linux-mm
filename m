Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDBB6B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:37:52 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y83so30029ita.5
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:37:52 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id z9si7958410itf.96.2018.03.06.10.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:37:51 -0800 (PST)
Date: Tue, 6 Mar 2018 12:37:49 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 06/25] slab: make kmem_cache_create() work with 32-bit
 sizes
In-Reply-To: <20180305200730.15812-6-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061235260.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-6-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Mon, 5 Mar 2018, Alexey Dobriyan wrote:

> struct kmem_cache::size and ::align were always 32-bit.
>
> Out of curiosity I created 4GB kmem_cache, it oopsed with division by 0.
> kmem_cache_create(1UL<<32+1) created 1-byte cache as expected.

Could you add a check to avoid that in the future?

> size_t doesn't work and never did.

Its not so simple. Please verify that the edge cases of all object size /
alignment etc calculations are doable with 32 bit entities first.

And size_t makes sense as a parameter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
