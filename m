Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 96BDF6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 12:39:51 -0400 (EDT)
Received: by igfj19 with SMTP id j19so16101491igf.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 09:39:51 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id 18si10123853iok.118.2015.08.25.09.39.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 09:39:50 -0700 (PDT)
Received: by igui7 with SMTP id i7so15566030igu.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 09:39:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87h9npwtx3.fsf@rasmusvillemoes.dk>
References: <20150823060443.GA9882@gmail.com>
	<20150823064603.14050.qmail@ns.horizon.com>
	<20150823081750.GA28349@gmail.com>
	<87h9npwtx3.fsf@rasmusvillemoes.dk>
Date: Tue, 25 Aug 2015 09:39:50 -0700
Message-ID: <CA+55aFwG_ifxOQ7YLqbrRF3kqx8XAMesB3MHG2LQ_SF9RQH7Xw@mail.gmail.com>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Ingo Molnar <mingo@kernel.org>, George Spelvin <linux@horizon.com>, Dave Hansen <dave@sr71.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Sun, Aug 23, 2015 at 2:56 PM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
>
> [Maybe one could just remove the fields and see if anybody actually
> notices/cares any longer. Or, if they are only used by kernel
> developers, put them in their own file.]

I'm actually inclined to try exactly that for 4.3, and then take
Ingo's patch as a fallback in case somebody actually notices.

I'm not convinced anybody actually uses those values, and they are
getting *less* relevant rather than more (on 64-bit, those values
really don't matter, since the vmalloc space isn't really a
limitation), so let's try removing them and seeing what happens. And
then we know what we can do if somebody does actually notice.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
