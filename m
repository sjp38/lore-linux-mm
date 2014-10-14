Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 143CA6B006E
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 10:54:53 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id g10so7575542pdj.4
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:54:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id jd10si1919764pbd.32.2014.10.14.07.54.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Oct 2014 07:54:51 -0700 (PDT)
Date: Tue, 14 Oct 2014 16:54:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
Message-ID: <20141014145435.GA7369@worktop.fdxtended.com>
References: <20141008191050.GK3778@sgi.com>
 <20141014114828.GA6524@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141014114828.GA6524@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Tue, Oct 14, 2014 at 02:48:28PM +0300, Kirill A. Shutemov wrote:

> Why whould you want to pin khugpeaged? Is there a valid use-case?
> Looks like userspace shoots to its leg.

Its just bad design to put so much work in another context. But the
use-case is isolating other cpus.

> Is there a reason why we should respect cpuset limitation for kernel
> threads?

Yes, because we want to allow isolating CPUs from 'random' activity.

> Should we bypass cpuset for PF_KTHREAD completely?

No. That'll break stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
