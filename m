Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A3C2F6B0038
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:36:07 -0400 (EDT)
Received: by wiun10 with SMTP id n10so22606324wiu.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:36:07 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id rz10si19764432wjb.13.2015.04.24.07.36.05
        for <linux-mm@kvack.org>;
        Fri, 24 Apr 2015 07:36:06 -0700 (PDT)
From: Daniel Sanders <Daniel.Sanders@imgtec.com>
Subject: RE: [PATCH v3] mm/slab_common: Support the slub_debug boot option
 on specific object size
Date: Fri, 24 Apr 2015 14:36:04 +0000
Message-ID: <E484D272A3A61B4880CDF2E712E9279F4597EF1B@hhmail02.hh.imgtec.org>
References: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com>
 <20150423140119.ef9480fd9561e23d0383dc06@linux-foundation.org>
In-Reply-To: <20150423140119.ef9480fd9561e23d0383dc06@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Gavin Guo <gavin.guo@canonical.com>
Cc: "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>

> This patch conflicts significantly with Daniel's "slab: correct
> size_index table before replacing the bootstrap kmem_cache_node".  I've
> reworked Daniel's patch as below.  Please review?

Your revised version of my patch looks good to me. I've also re-tested LLVM=
Linux
with Gavin's and my (revised) patch applied and it's still working.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
