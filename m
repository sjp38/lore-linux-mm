Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5266C6B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 11:34:13 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so170020wib.17
        for <linux-mm@kvack.org>; Mon, 26 May 2014 08:34:12 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id o12si584508wiv.36.2014.05.26.08.34.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 May 2014 08:34:12 -0700 (PDT)
Message-Id: <20140526145605.016140154@infradead.org>
Date: Mon, 26 May 2014 16:56:05 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 0/5] VM_PINNED
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>, Peter Zijlstra <peterz@infradead.org>

Hi all,

I mentioned at LSF/MM that I wanted to revive this, and at the time there were
no disagreements.

I finally got around to refreshing the patch(es) so here goes.

These patches introduce VM_PINNED infrastructure, vma tracking of persistent
'pinned' page ranges. Pinned is anything that has a fixed phys address (as
required for say IO DMA engines) and thus cannot use the weaker VM_LOCKED. One
popular way to pin pages is through get_user_pages() but that not nessecarily
the only way.

Roland, as said, I need some IB assistance, see patches 4 and 5, where I got
lost in the qib and ipath code.

Patches 1-3 compile tested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
