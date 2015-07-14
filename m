Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id F24D6280250
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:24:06 -0400 (EDT)
Received: by pacan13 with SMTP id an13so11649200pac.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:24:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bm1si3722494pbd.212.2015.07.14.14.24.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 14:24:06 -0700 (PDT)
Date: Tue, 14 Jul 2015 14:24:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
Message-Id: <20150714142404.30f6a2255f5bd72c5b332279@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1507141401170.16182@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com>
	<20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
	<alpine.LRH.2.02.1507081855340.32526@file01.intranet.prod.int.rdu2.redhat.com>
	<20150708161815.bdff609d77868dbdc2e1ce64@linux-foundation.org>
	<alpine.LRH.2.02.1507091039440.30842@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.DEB.2.10.1507141401170.16182@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 14 Jul 2015 14:13:16 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> There's a misunderstanding in regards to the comment: __GFP_NORETRY 
> doesn't turn direct reclaim or compaction off, it is still attempted and 
> with the same priority as any other allocation.  This only stops the page 
> allocator from calling the oom killer, which will free memory or panic the 
> system, and looping when memory is available.

include/linux/gfp.h says

 * __GFP_NORETRY: The VM implementation must not retry indefinitely.

Can you suggest something more accurate and complete which we can put there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
