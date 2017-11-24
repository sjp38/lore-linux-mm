Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id F201E6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 12:31:49 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id s37so28786036ioe.1
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 09:31:49 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id 20si15088642ion.130.2017.11.24.09.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 09:31:48 -0800 (PST)
Date: Fri, 24 Nov 2017 11:31:47 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 21/23] slub: make struct kmem_cache_order_objects::x
 unsigned int
In-Reply-To: <20171123221628.8313-21-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1711241130540.19616@nuc-kabylake>
References: <20171123221628.8313-1-adobriyan@gmail.com> <20171123221628.8313-21-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

On Fri, 24 Nov 2017, Alexey Dobriyan wrote:

> !!! Patch assumes that "PAGE_SIZE << order" doesn't overflow. !!!

Check for that condition and do not allow creation of such caches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
