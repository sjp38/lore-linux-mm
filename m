Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3316B0038
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 10:36:58 -0400 (EDT)
Received: by igui7 with SMTP id i7so31398529igu.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 07:36:57 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id u34si3962306ioi.166.2015.08.22.07.36.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Aug 2015 07:36:57 -0700 (PDT)
Received: by iodv127 with SMTP id v127so108913941iod.3
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 07:36:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440240300-6206-1-git-send-email-mingo@kernel.org>
References: <1440240300-6206-1-git-send-email-mingo@kernel.org>
Date: Sat, 22 Aug 2015 07:36:56 -0700
Message-ID: <CA+55aFzgqtZj6_kRUbh5CrSNQtJ+es3cndnJXfBL-uA_CEfqrg@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm/vmalloc: Cache the /proc/meminfo vmalloc statistics
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave@sr71.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Sat, Aug 22, 2015 at 3:44 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> Would something like this be acceptable (and is it correct)?

I don't think any of this can be called "correct", in that the
unlocked accesses to the cached state are clearly racy, but I think
it's very much "acceptable".

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
