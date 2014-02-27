Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id A57F46B0069
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 19:17:21 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id hq11so1755181vcb.14
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 16:17:21 -0800 (PST)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id fi2si69955vdb.88.2014.02.26.16.17.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 16:17:20 -0800 (PST)
Received: by mail-vc0-f181.google.com with SMTP id lg15so1760134vcb.12
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 16:17:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393459641.25123.21.camel@buesod1.americas.hpqcorp.net>
References: <1393459641.25123.21.camel@buesod1.americas.hpqcorp.net>
Date: Wed, 26 Feb 2014 16:17:17 -0800
Message-ID: <CA+55aFyG=UroQxhpfiU-fah7m_O3TFxdbo-S-eUGApddP-zsgA@mail.gmail.com>
Subject: Re: [PATCH v3] mm: per-thread vma caching
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Ok, I think this is in a mergable form.

I wonder what the heck that insane tlb flush is in
kgdb_flush_swbreak_addr(), but it predates this, and while it makes no
sense to me, the patch makes it no worse. And I can't find it in
myself to care.

Does anybody see anything odd? If not, add an acked-by from me and put
it in -mm, or what?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
