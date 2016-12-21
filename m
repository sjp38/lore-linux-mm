Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 158BC6B03BF
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 12:30:38 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j15so27112626ioj.7
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 09:30:38 -0800 (PST)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id g63si20397974ioa.86.2016.12.21.09.30.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 09:30:37 -0800 (PST)
Received: by mail-it0-x243.google.com with SMTP id c20so18069511itb.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 09:30:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161221151951.16396-1-npiggin@gmail.com>
References: <20161221151951.16396-1-npiggin@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 21 Dec 2016 09:30:36 -0800
Message-ID: <CA+55aFw_uQ9gh=UUJCx4FVYYu0wNYjt1vgyfYSRU4FH6+c8t2A@mail.gmail.com>
Subject: Re: [PATCH 0/2] respin of PageWaiters patch
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Wed, Dec 21, 2016 at 7:19 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
> Seeing as Mel said he would test it (and maybe Dave could as well), I
> will post my patches again. There was a couple of page flags bugs pointed
> out last time, which should be fixed.

So I already had Dave test the previous version, and the preliminary
data was good.

I guess we should just apply it. This is not improved by me dropping
it on the floor once more, and thinking that the problem is gone by
knowing that we can solve it.

But your respun patches don't have commit messages and sign-offs.. Hint hint

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
