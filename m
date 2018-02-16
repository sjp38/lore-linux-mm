Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF2516B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 15:13:16 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id l128so4110268ioe.14
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:13:16 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id g82si1728082iog.34.2018.02.16.12.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 12:13:15 -0800 (PST)
Date: Fri, 16 Feb 2018 14:13:12 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
In-Reply-To: <5108eb20-2b20-bd48-903e-bce312e96974@oracle.com>
Message-ID: <alpine.DEB.2.20.1802161411440.11934@nuc-kabylake>
References: <20180216160110.641666320@linux.com> <20180216160121.519788537@linux.com> <5108eb20-2b20-bd48-903e-bce312e96974@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>

On Fri, 16 Feb 2018, Mike Kravetz wrote:

> > Well that f.e brings up huge pages. You can of course
> > also use this to reserve those and can then be sure that
> > you can dynamically resize your huge page pools even after
> > a long time of system up time.
>
> Yes, and no.  Doesn't that assume nobody else is doing allocations
> of that size?  For example, I could image THP using huge page sized
> reservations.  The when it comes time to resize your hugetlbfs pool
> there may not be enough.  Although, we may quickly split THP pages
> in this case.  I am not sure.

Yup it has a pool for everyone. Question is how to divide the loot ;-)

> IIRC, Guy Shattah's use case was for allocations greater than MAX_ORDER.
> This would not directly address that.  A huge contiguous area (2GB) is
> the sweet spot' for best performance in his case.  However, I think he
> could still benefit from using a set of larger (such as 2MB) size
> allocations which this scheme could help with.

MAX_ORDER can be increased to allow for larger allocations. IA64 has f.e.
a much larger MAX_ORDER size. So does powerpc. And then the reservation
scheme will work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
