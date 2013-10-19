Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0642E6B0262
	for <linux-mm@kvack.org>; Sat, 19 Oct 2013 18:39:57 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so3774448pdj.36
        for <linux-mm@kvack.org>; Sat, 19 Oct 2013 15:39:57 -0700 (PDT)
Received: from psmtp.com ([74.125.245.153])
        by mx.google.com with SMTP id dl5si4523095pbd.236.2013.10.19.15.39.56
        for <linux-mm@kvack.org>;
        Sat, 19 Oct 2013 15:39:57 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 00/15] slab: overload struct slab over struct page to reduce memory usage
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
Date: Sat, 19 Oct 2013 15:39:34 -0700
In-Reply-To: <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
	(Andrew Morton's message of "Wed, 16 Oct 2013 13:34:57 -0700")
Message-ID: <8738nwvqah.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Andrew Morton <akpm@linux-foundation.org> writes:
>
> One example is mm/memory-failure.c:memory_failure().  It starts with a
> raw pfn, uses that to get at the `struct page', then starts playing
> around with it.  Will that code still work correctly when some of the
> page's fields have been overlayed with slab-specific contents?

As long as PageSlab() works correctly memory_failure should be happy.

>
> This issue hasn't been well thought through.  Given a random struct
> page, there isn't any protocol to determine what it actually *is*. 
> It's a plain old variant record, but it lacks the agreed-upon tag field
> which tells users which variant is currently in use.

PageSlab() should work for this right?

For the generic case it may not though.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
