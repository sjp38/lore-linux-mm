Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3966B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 13:11:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q11so5026928pfd.8
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 10:11:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c22si4901817pfe.29.2018.04.13.10.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 10:11:22 -0700 (PDT)
Date: Fri, 13 Apr 2018 10:11:20 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
Message-ID: <20180413171120.GA1245@bombadil.infradead.org>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413131632.1413-3-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

On Fri, Apr 13, 2018 at 03:16:26PM +0200, David Hildenbrand wrote:
> online_pages()/offline_pages() theoretically allows us to work on
> sub-section sizes. This is especially relevant in the context of
> virtualization. It e.g. allows us to add/remove memory to Linux in a VM in
> 4MB chunks.
> 
> While the whole section is marked as online/offline, we have to know
> the state of each page. E.g. to not read memory that is not online
> during kexec() or to properly mark a section as offline as soon as all
> contained pages are offline.

Can you not use PG_reserved for this purpose?

> + * PG_offline indicates that a page is offline and the backing storage
> + * might already have been removed (virtualization). Don't touch!

 * PG_reserved is set for special pages, which can never be swapped out. Some
 * of them might not even exist...

They seem pretty congruent to me.
