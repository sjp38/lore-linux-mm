Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF10B6B038A
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 17:32:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 81so281055534pgh.3
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 14:32:29 -0700 (PDT)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id o12si18881476plg.220.2017.03.20.14.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Mar 2017 14:32:29 -0700 (PDT)
Received: by mail-pg0-x229.google.com with SMTP id n190so83474823pga.0
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 14:32:29 -0700 (PDT)
Date: Mon, 20 Mar 2017 14:32:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2 1/2] mm, swap: Use kvzalloc to allocate some swap
 data structure
In-Reply-To: <20170320084732.3375-1-ying.huang@intel.com>
Message-ID: <alpine.DEB.2.10.1703201430550.24991@chino.kir.corp.google.com>
References: <20170320084732.3375-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Mar 2017, Huang, Ying wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> Now vzalloc() is used in swap code to allocate various data
> structures, such as swap cache, swap slots cache, cluster info, etc.
> Because the size may be too large on some system, so that normal
> kzalloc() may fail.  But using kzalloc() has some advantages, for
> example, less memory fragmentation, less TLB pressure, etc.  So change
> the data structure allocation in swap code to use kvzalloc() which
> will try kzalloc() firstly, and fallback to vzalloc() if kzalloc()
> failed.
> 

As questioned in -v1 of this patch, what is the benefit of directly 
compacting and reclaiming memory for high-order pages by first preferring 
kmalloc() if this does not require contiguous memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
