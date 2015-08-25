Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 49D606B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:11:56 -0400 (EDT)
Received: by ykdt205 with SMTP id t205so160169782ykd.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:11:56 -0700 (PDT)
Received: from ns.horizon.com (ns.horizon.com. [71.41.210.147])
        by mx.google.com with SMTP id z62si12585071ywd.170.2015.08.25.08.11.55
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 08:11:55 -0700 (PDT)
Date: 25 Aug 2015 11:11:54 -0400
Message-ID: <20150825151154.19516.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 3/3 v6] mm/vmalloc: Cache the vmalloc memory info
In-Reply-To: <87io83wiuo.fsf@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@rasmusvillemoes.dk, mingo@kernel.org
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@horizon.com, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

>>> (I hope I'm not annoying you by bikeshedding this too much, although I
>>> think this is improving.)
>>
>> [ I don't mind, although I wish other, more critical parts of the kernel got this
>>   much attention as well ;-) ]

That's the problem with small, understandable problems: people *aren't*
scared to mess with them.

> It's been fun seeing this evolve, but overall, I tend to agree with
> Peter: It's a lot of complexity for little gain. If we're not going to
> just kill the Vmalloc* fields (which is probably too controversial)
> I'd prefer Linus' simpler version.

Are you sure you're not being affected by the number of iterations?

The final version is not actually a lot of code (although yes, more than
Linus's), and offers the advantage of peace of mind: there's not some
nasty-smelling code you can't entirely trust left behind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
