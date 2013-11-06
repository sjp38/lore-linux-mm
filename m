Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2504B6B00AC
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 19:42:22 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kq14so9607708pab.7
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 16:42:21 -0800 (PST)
Received: from psmtp.com ([74.125.245.198])
        by mx.google.com with SMTP id p2si993176pbe.308.2013.11.05.16.42.19
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 16:42:20 -0800 (PST)
Date: Tue, 5 Nov 2013 16:43:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: create a separate slab for page->ptl allocation
Message-Id: <20131105164351.b2c63109.akpm@linux-foundation.org>
In-Reply-To: <20131105231310.GE20167@shutemov.name>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
	<20131105224217.GC20167@shutemov.name>
	<20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
	<20131105231310.GE20167@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Wed, 6 Nov 2013 01:13:11 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > Really the function shouldn't exist in this case.  It is __init so the
> > sin is not terrible, but can this be arranged?
> 
> I would like to get rid of __ptlock_alloc()/__ptlock_free() too, but I
> don't see a way within C: we need to know sizeof(spinlock_t) on
> preprocessor stage.
> 
> We can have a hack on kbuild level: write small helper program to find out
> sizeof(spinlock_t) before start building and turn it into define.
> But it's overkill from my POV. And cross-compilation will be a fun.

Yes, it doesn't seem worth the fuss.  The compiler will remove all this
code anyway, so for example ptlock_cache_init() becomes an empty function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
