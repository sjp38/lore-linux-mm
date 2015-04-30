Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id ABAE26B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 14:41:01 -0400 (EDT)
Received: by iejt8 with SMTP id t8so74605594iej.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 11:41:01 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id z5si1938335igg.2.2015.04.30.11.41.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 11:41:00 -0700 (PDT)
Date: Thu, 30 Apr 2015 13:40:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: bulk allocation from per cpu partial pages
In-Reply-To: <20150417080610.4ae80965@redhat.com>
Message-ID: <alpine.DEB.2.11.1504301340150.28784@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org> <20150408155304.4480f11f16b60f09879c350d@linux-foundation.org> <alpine.DEB.2.11.1504090859560.19278@gentwo.org> <alpine.DEB.2.11.1504091215330.18198@gentwo.org> <20150416140638.684838a2@redhat.com>
 <alpine.DEB.2.11.1504161049030.8605@gentwo.org> <20150417074446.6dd16121@redhat.com> <20150417080610.4ae80965@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Fri, 17 Apr 2015, Jesper Dangaard Brouer wrote:

> > Ups, I can see that this kernel don't have CONFIG_SLUB_CPU_PARTIAL,
> > I'll re-run tests with this enabled.
>
> Results with CONFIG_SLUB_CPU_PARTIAL.
>
>  size    --  optimized -- fallback
>  bulk  8 --  16ns      -- 22ns
>  bulk 16 --  16ns      -- 22ns
>  bulk 30 --  16ns      -- 22ns
>  bulk 32 --  16ns      -- 22ns
>  bulk 64 --  30ns      -- 38ns

That looks better. Can I get the code for testing? Then I can vary the
approach a bit before posting patches? I still want to add a fast path for
allocation from the per node partial list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
