Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 73C326B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 16:27:24 -0400 (EDT)
Received: by pddn5 with SMTP id n5so90234238pdd.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 13:27:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dr4si13021031pdb.162.2015.04.07.13.27.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 13:27:23 -0700 (PDT)
Date: Tue, 7 Apr 2015 13:27:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mm: Refactor remap_pfn_range()
Message-Id: <20150407132721.7dbeee3218b8f185794b4f37@linux-foundation.org>
In-Reply-To: <1428424299-13721-3-git-send-email-chris@chris-wilson.co.uk>
References: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
	<1428424299-13721-3-git-send-email-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, intel-gfx@lists.freedesktop.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Tue,  7 Apr 2015 17:31:36 +0100 Chris Wilson <chris@chris-wilson.co.uk> wrote:

> In preparation for exporting very similar functionality through another
> interface, gut the current remap_pfn_range(). The motivating factor here
> is to reuse the PGB/PUD/PMD/PTE walker, but allow back progation of
> errors rather than BUG_ON.

I'm not on intel-gfx and for some reason these patches didn't show up on
linux-mm.  I wanted to comment on "mutex: Export an interface to wrap a
mutex lock" but
http://lists.freedesktop.org/archives/intel-gfx/2015-April/064063.html
doesn't tell me which mailing lists were cc'ed and I can't find that
patch on linux-kernel.

Can you please do something to make this easier for us??

And please fully document all the mutex interfaces which you just
added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
