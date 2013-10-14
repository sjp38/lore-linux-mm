Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 324846B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 15:04:08 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so7825101pab.8
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 12:04:07 -0700 (PDT)
Date: Mon, 14 Oct 2013 19:04:05 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 34/34] mm: dynamically allocate page->ptl if it cannot
 be embedded to struct page
In-Reply-To: <20131014090437.F22CBE0090@blue.fi.intel.com>
Message-ID: <00000141b85a90a0-7cf6bab0-4c17-4fc0-8224-74bbb1fc85ee-000000@email.amazonses.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com> <1381428359-14843-35-git-send-email-kirill.shutemov@linux.intel.com> <00000141a3f48ada-37ee9c14-2f2b-40a2-93f4-70258363351b-000000@email.amazonses.com> <20131010200921.91D84E0090@blue.fi.intel.com>
 <00000141a7d2aa7b-e59f292a-746c-4f55-aa51-9fa060a7fbeb-000000@email.amazonses.com> <20131014090437.F22CBE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Mon, 14 Oct 2013, Kirill A. Shutemov wrote:

> > > > Could you make the check a CONFIG option? CONFIG_PTLOCK_DOES_NOT_FIT_IN_PAGE_STRUCT or
> > > > so?
> > >
> > > No. We will have to track what affects sizeof(spinlock_t) manually.
> > > Not a fun and error prune.
> >
> > You can generate a config option depending on the size of the object via
> > Kbuild. Kbuild will determine the setting before building the kernel as a
> > whole by runing some small C program.
>
> I don't think it's any better than what we have there now.

Well with the CONFIG options we can then create macros etc that handle
things differently depending on the ptl being in the page or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
