Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10ED96B026F
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 08:53:58 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id z142so22431932itc.6
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 05:53:58 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v28si9942913ite.6.2017.12.18.05.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 05:53:56 -0800 (PST)
Date: Mon, 18 Dec 2017 14:53:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: Reduce memory bloat with THP
Message-ID: <20171218135345.owvmwf2koe64ny7j@hirez.programming.kicks-ass.net>
References: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
 <20171215100024.gxuijdovjhkugarz@node.shutemov.name>
 <d3e77b2c-2164-743d-4f88-527091790006@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d3e77b2c-2164-743d-4f88-527091790006@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitin.m.gupta@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, SeongJae Park <sj38.park@gmail.com>, Shaohua Li <shli@fb.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, open list <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 11:04:03PM -0800, Nitin Gupta wrote:
> >> Orabug: 26910556
> > 
> > Wat?
> > 
> 
> It's oracle internal identifier used to track this work.

And as such has no place what so ever outside of oracle. Do not include
junk like that in upstream patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
