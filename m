Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id B164C6B0274
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 10:14:41 -0400 (EDT)
Received: by igr7 with SMTP id 7so41628365igr.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 07:14:41 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id o19si9677926igs.5.2015.07.21.07.14.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 07:14:40 -0700 (PDT)
Received: by iecri3 with SMTP id ri3so48284534iec.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 07:14:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
Date: Tue, 21 Jul 2015 09:14:40 -0500
Message-ID: <CAPp3RGryq96pEErEw8x=UV_=xsZS4ACD15uAEaOVT5CgcLzzEQ@mail.gmail.com>
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
From: Robin Holt <robinmholt@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Christoph Lameter <cl@linux.com>, Cliff Whickman <cpw@sgi.com>

On Tue, Jul 21, 2015 at 8:55 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
> allocator: do not check NUMA node ID when the caller knows the node is valid")
> as an optimized variant of alloc_pages_node(), that doesn't allow the node id
> to be -1. Unfortunately the name of the function can easily suggest that the
> allocation is restricted to the given node. In truth, the node is only
> preferred, unless __GFP_THISNODE is among the gfp flags.
>
...
> Cc: Robin Holt <robinmholt@gmail.com>

Acked-by: Robin Holt <robinmholt@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
