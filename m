Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 528B16B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 13:24:18 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so21450895wid.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:24:18 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id en7si40087807wjd.61.2015.08.25.10.24.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 10:24:16 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so22582965wid.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:24:16 -0700 (PDT)
Date: Tue, 25 Aug 2015 20:24:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 1/5] mm: drop page->slab_page
Message-ID: <20150825172414.GB4881@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-2-git-send-email-kirill.shutemov@linux.intel.com>
 <55DB31F8.4020200@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55DB31F8.4020200@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>

On Mon, Aug 24, 2015 at 05:02:16PM +0200, Vlastimil Babka wrote:
> On 08/19/2015 11:21 AM, Kirill A. Shutemov wrote:
> >Since 8456a648cf44 ("slab: use struct page for slab management") nobody
> >uses slab_page field in struct page.
> >
> >Let's drop it.
> 
> Ah, how about dropping this comment in mm/slab.c:slab_destroy() as well?
> 
>                 /*
>                  * RCU free overloads the RCU head over the LRU.
>                  * slab_page has been overloeaded over the LRU,
>                  * however it is not used from now on so that
>                  * we can use it safely.
>                  */

Actually, whole block can be replaced by

	call_rcu(&page->rcu_head, kmem_rcu_free);

Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
