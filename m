Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDBD6B0164
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 11:09:18 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kp14so821510pab.1
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 08:09:18 -0800 (PST)
Received: from psmtp.com ([74.125.245.160])
        by mx.google.com with SMTP id yj4si3449448pac.340.2013.11.07.08.09.16
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 08:09:17 -0800 (PST)
Date: Thu, 7 Nov 2013 16:09:15 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: Switch slub_debug kernel option to early_param
 to avoid boot panic
In-Reply-To: <20131107084129.GP5661@alberich>
Message-ID: <0000014233531ff8-0f4331f9-5da3-4cc8-9c30-a40681228446-000000@email.amazonses.com>
References: <20131106184529.GB5661@alberich> <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com> <20131106195417.GK5661@alberich> <20131106203429.GL5661@alberich> <20131106211604.GM5661@alberich>
 <000001422f59e79e-ba0d30e2-fe7d-4e6f-9029-65dc5978fe60-000000@email.amazonses.com> <20131107082732.GN5661@alberich> <20131107084129.GP5661@alberich>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="376175846-243750884-1383840561=:22533"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Herrmann <andreas.herrmann@calxeda.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--376175846-243750884-1383840561=:22533
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Thu, 7 Nov 2013, Andreas Herrmann wrote:

> And for sake of completeness. Here is some debug output with a kernel
> that had your "slub: Handle NULL parameter in kmem_cache_flags" patch
> applied. And of course there were a couple of unnamed slabs:
>
>   ...
>          .bss : 0xc089fd80 - 0xc094cc4c   ( 692 kB)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (c06fc90c): kmem_cache_node
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (c06fc91c): kmem_cache
> a?? slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
>   SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
>   ...

Well yes on bootstrap the slabs are initially created without a name.
Later the name is provided. Before the introduction of the common kmalloc
code the kmalloc caches had a generic name instead of NULL. I was not sure
that this was a valid thing to do so I put NULL in there so that we can
catch the uses.

--376175846-243750884-1383840561=:22533--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
