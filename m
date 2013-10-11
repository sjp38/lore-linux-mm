Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 11F2B6B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 12:31:08 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so4452977pbc.32
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 09:31:07 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1381428359-14843-16-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-16-git-send-email-kirill.shutemov@linux.intel.com> <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 15/34] frv: handle pgtable_page_ctor() fail
Date: Fri, 11 Oct 2013 17:30:10 +0100
Message-ID: <15762.1381509010@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org


Acked-by: David Howells <dhowells@redhat.com>

for the FRV and MN10300 patches.

Can you move pte_alloc_one() to common code, at least for some arches?  I
think that the FRV and MN10300 ones should end up the same after this - and I
wouldn't be surprised if some of the other arches do too.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
