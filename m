Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFFE6B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:00:06 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so62308118wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:00:06 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id f8si19770945wiz.88.2015.08.24.00.00.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 00:00:05 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so62692471wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:00:04 -0700 (PDT)
Date: Mon, 24 Aug 2015 09:00:01 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150824070001.GB13082@gmail.com>
References: <20150823060443.GA9882@gmail.com>
 <20150823064603.14050.qmail@ns.horizon.com>
 <20150823081750.GA28349@gmail.com>
 <87h9npwtx3.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87h9npwtx3.fsf@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org


* Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> I was curious why these fields were ever added to /proc/meminfo, and dug
> up this:
> 
> commit d262ee3ee6ba4f5f6125571d93d9d63191d2ef76
> Author: Andrew Morton <akpm@digeo.com>
> Date:   Sat Apr 12 12:59:04 2003 -0700
> 
>     [PATCH] vmalloc stats in /proc/meminfo
>     
>     From: Matt Porter <porter@cox.net>
>     
>     There was a thread a while back on lkml where Dave Hansen proposed this
>     simple vmalloc usage reporting patch.  The thread pretty much died out as
>     most people seemed focused on what VM loading type bugs it could solve.  I
>     had posted that this type of information was really valuable in debugging
>     embedded Linux board ports.  A common example is where people do arch
>     specific setup that limits there vmalloc space and then they find modules
>     won't load.  ;) Having the Vmalloc* info readily available is real useful in
>     helping folks to fix their kernel ports.
> 
> That thread is at <http://thread.gmane.org/gmane.linux.kernel/53360>.
> 
> [Maybe one could just remove the fields and see if anybody actually
> notices/cares any longer. Or, if they are only used by kernel
> developers, put them in their own file.]

So instead of removing the fields (which I'm quite sure is an ABI breaker as it 
could break less robust /proc/meminfo parsers and scripts), we could just report 
'0' all the time - and have the real info somewhere else?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
