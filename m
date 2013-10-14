Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE836B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 18:13:51 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so7859491pbc.35
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 15:13:50 -0700 (PDT)
Date: Mon, 14 Oct 2013 22:13:48 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 34/34] mm: dynamically allocate page->ptl if it cannot
 be embedded to struct page
In-Reply-To: <20131014212514.C7C19E0090@blue.fi.intel.com>
Message-ID: <00000141b90841a8-3fb61f1e-89aa-4a35-94d4-a264ac91462b-000000@email.amazonses.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com> <1381428359-14843-35-git-send-email-kirill.shutemov@linux.intel.com> <00000141a3f48ada-37ee9c14-2f2b-40a2-93f4-70258363351b-000000@email.amazonses.com> <20131010200921.91D84E0090@blue.fi.intel.com>
 <00000141a7d2aa7b-e59f292a-746c-4f55-aa51-9fa060a7fbeb-000000@email.amazonses.com> <20131014090437.F22CBE0090@blue.fi.intel.com> <00000141b85a90a0-7cf6bab0-4c17-4fc0-8224-74bbb1fc85ee-000000@email.amazonses.com>
 <20131014212514.C7C19E0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Tue, 15 Oct 2013, Kirill A. Shutemov wrote:

> Feel free to propose a patch. I don't see much point.

Right now you are using a long to stand in for a spinlock_t or a pointer
to a spinlock_t. An #ifdef would allow to define the proper type and
therefore the compiler to check that the ptl is correctly used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
