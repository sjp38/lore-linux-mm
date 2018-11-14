Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 98F486B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:23:25 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a72-v6so14337208pfj.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:23:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f15si116956plr.144.2018.11.14.14.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 14:23:24 -0800 (PST)
Date: Wed, 14 Nov 2018 14:23:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC 2/6] mm: convert PG_balloon to PG_offline
Message-ID: <20181114222321.GB1784@bombadil.infradead.org>
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114211704.6381-3-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Jonathan Corbet <corbet@lwn.net>, Alexey Dobriyan <adobriyan@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Hansen <chansen3@cisco.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Miles Chen <miles.chen@mediatek.com>, David Rientjes <rientjes@google.com>

On Wed, Nov 14, 2018 at 10:17:00PM +0100, David Hildenbrand wrote:
> Rename PG_balloon to PG_offline. This is an indicator that the page is
> logically offline, the content stale and that it should not be touched
> (e.g. a hypervisor would have to allocate backing storage in order for the
> guest to dump an unused page).  We can then e.g. exclude such pages from
> dumps.
> 
> In following patches, we will make use of this bit also in other balloon
> drivers.  While at it, document PGTABLE.

Thank you for documenting PGTABLE.  I didn't realise I also had this
document to update when I added PGTABLE.

> +++ b/Documentation/admin-guide/mm/pagemap.rst
> @@ -78,6 +78,8 @@ number of times a page is mapped.
>      23. BALLOON
>      24. ZERO_PAGE
>      25. IDLE
> +    26. PGTABLE
> +    27. OFFLINE

So the offline *user* bit is new ... even though the *kernel* bit
just renames the balloon bit.  I'm not sure how I feel about this.
I'm going to think about it some more.  Could you share your decision
process with us?

I have no objection to renaming the balloon bit inside the kernel; I
think that's a wise idea.  I'm just not sure whether we should rename
the user balloon bit rather than adding a new bit.
