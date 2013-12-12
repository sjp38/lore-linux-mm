Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id C5C836B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:46:04 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so593866yhn.32
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 09:46:04 -0800 (PST)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTP id b6si19488242qak.6.2013.12.12.09.46.03
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 09:46:03 -0800 (PST)
Date: Thu, 12 Dec 2013 17:46:02 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 2/3] mm: slab: move around slab ->freelist for
 cmpxchg
In-Reply-To: <20131211224025.70B40B9C@viggo.jf.intel.com>
Message-ID: <00000142e7ea519d-8906d225-c99c-44b5-b381-b573c75fd097-000000@email.amazonses.com>
References: <20131211224022.AA8CF0B9@viggo.jf.intel.com> <20131211224025.70B40B9C@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On Wed, 11 Dec 2013, Dave Hansen wrote:

>
> The write-argument to cmpxchg_double() must be 16-byte aligned.
> We used to align 'struct page' itself in order to guarantee this,
> but that wastes 8-bytes per page.  Instead, we take 8-bytes
> internal to the page before page->counters and move freelist
> between there and the existing 8-bytes after counters.  That way,
> no matter how 'stuct page' itself is aligned, we can ensure that
> we have a 16-byte area with which to to this cmpxchg.

Well this adds additional branching to the fast paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
