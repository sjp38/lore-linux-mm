Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11C606B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 12:22:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 123so12087458wmb.7
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 09:22:44 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id o2si22996115wjr.120.2016.10.07.09.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 09:22:42 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id b201so49747695wmb.0
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 09:22:42 -0700 (PDT)
Date: Fri, 7 Oct 2016 17:22:40 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
Message-ID: <20161007162240.GA14350@lucifer>
References: <20160911225425.10388-1-lstoakes@gmail.com>
 <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
 <1474842875.17726.38.camel@redhat.com>
 <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
 <20161007100720.GA14859@lucifer>
 <CA+55aFzOYk_1Jcr8CSKyqfkXaOApZvCkX0_27mZk7PvGSE4xSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzOYk_1Jcr8CSKyqfkXaOApZvCkX0_27mZk7PvGSE4xSw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 07, 2016 at 08:34:15AM -0700, Linus Torvalds wrote:
> Would you be willing to look at doing that kind of purely syntactic,
> non-semantic cleanup first?

Sure, more than happy to do that! I'll work on a patch for this.

> I think that if we end up having the FOLL_FORCE semantics, we're
> actually better off having an explicit FOLL_FORCE flag, and *not* do
> some kind of implicit "under these magical circumstances we'll force
> it anyway". The implicit thing is what we used to do long long ago, we
> definitely don't want to.

That's a good point, it would definitely be considerably more 'magical', and
expanding the conditions to include uprobes etc. would only add to that.

I wondered about an alternative parameter/flag but it felt like it was
more-or-less FOLL_FORCE in a different form, at which point it may as well
remain FOLL_FORCE :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
