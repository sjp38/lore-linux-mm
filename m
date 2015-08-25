Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7246B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 13:03:22 -0400 (EDT)
Received: by igbjg10 with SMTP id jg10so17963167igb.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:03:22 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id m33si10175315iod.140.2015.08.25.10.03.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 10:03:21 -0700 (PDT)
Received: by igfj19 with SMTP id j19so16225199igf.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:03:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwG_ifxOQ7YLqbrRF3kqx8XAMesB3MHG2LQ_SF9RQH7Xw@mail.gmail.com>
References: <20150823060443.GA9882@gmail.com>
	<20150823064603.14050.qmail@ns.horizon.com>
	<20150823081750.GA28349@gmail.com>
	<87h9npwtx3.fsf@rasmusvillemoes.dk>
	<CA+55aFwG_ifxOQ7YLqbrRF3kqx8XAMesB3MHG2LQ_SF9RQH7Xw@mail.gmail.com>
Date: Tue, 25 Aug 2015 10:03:21 -0700
Message-ID: <CA+55aFxFwxPJftz52NyaeAqAAB0=tmp8cDrToW6_AoNp5apbow@mail.gmail.com>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Ingo Molnar <mingo@kernel.org>, George Spelvin <linux@horizon.com>, Dave Hansen <dave@sr71.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Tue, Aug 25, 2015 at 9:39 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I'm not convinced anybody actually uses those values, and they are
> getting *less* relevant rather than more (on 64-bit, those values
> really don't matter, since the vmalloc space isn't really a
> limitation)

Side note: the people who actually care about "my vmalloc area is too
full, what's up?" would use /proc/vmallocinfo anyway, since that's
what shows things like fragmentation etc.

So I'm just talking about removing the /proc/meminfo part. First try
to remove it *all*, and if there is some script that hollers because
it wants to parse them, print out the values as zero.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
