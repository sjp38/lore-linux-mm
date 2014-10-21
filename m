Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D92C66B0092
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:41:36 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so1146945pab.16
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 03:41:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id wl10si10534736pbc.211.2014.10.21.03.41.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 03:41:35 -0700 (PDT)
Date: Tue, 21 Oct 2014 12:41:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 5/6] mm: Provide speculative fault infrastructure
Message-ID: <20141021104130.GA12706@worktop.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.490529442@infradead.org>
 <20141021083548.GA22200@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021083548.GA22200@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 21, 2014 at 11:35:48AM +0300, Kirill A. Shutemov wrote:
> pud_huge() too. Or filter out VM_HUGETLB altogether.

Oh right, giga pages, all this new fangled stuff ;-) But yes, I suppose
we can exclude hugetlbfs, we should arguably make the thp muck work
though.

> BTW, what keeps mm_struct around? It seems we don't take reference during
> page fault.

Last I checked tasks have a ref on their own mm, and seeing this all
runs in task context, the mm should be pretty safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
