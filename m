Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0997F6B0038
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 17:22:52 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g74so51346975ioi.4
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 14:22:52 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id 186si3753267itk.52.2017.04.30.14.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 14:22:51 -0700 (PDT)
Date: Sun, 30 Apr 2017 16:22:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] try to save some memory for kmem_cache in some
 cases
In-Reply-To: <20170430113152.6590-1-richard.weiyang@gmail.com>
Message-ID: <alpine.DEB.2.20.1704301621170.21370@east.gentwo.org>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 30 Apr 2017, Wei Yang wrote:

> kmem_cache is a frequently used data in kernel. During the code reading, I
> found maybe we could save some space in some cases.
>
> 1. On 64bit arch, type int will occupy a word if it doesn't sit well.
> 2. cpu_slab->partial is just used when CONFIG_SLUB_CPU_PARTIAL is set
> 3. cpu_partial is just used when CONFIG_SLUB_CPU_PARTIAL is set, while just
> save some space on 32bit arch.

This looks fine. But do we really want to add that amount of ifdeffery?
How much memory does this save?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
