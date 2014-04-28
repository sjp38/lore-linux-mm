Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 275446B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 18:25:56 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id hu19so9299505vcb.9
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:25:55 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id ls10si4021919vec.172.2014.04.28.15.25.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 15:25:55 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hq16so6599651vcb.11
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:25:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1398723290.25549.20.camel@buesod1.americas.hpqcorp.net>
References: <535EA976.1080402@linux.vnet.ibm.com>
	<CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
	<CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
	<alpine.LSU.2.11.1404281500180.2861@eggly.anvils>
	<1398723290.25549.20.camel@buesod1.americas.hpqcorp.net>
Date: Mon, 28 Apr 2014 15:25:55 -0700
Message-ID: <CA+55aFwGjYS7PqsD6A-q+Yp9YZmiM6mB4MUYmfR7ro02poxxCQ@mail.gmail.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Hugh Dickins <hughd@google.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Mon, Apr 28, 2014 at 3:14 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>
> I think that returning some stale/bogus vma is causing those segfaults
> in udev. It shouldn't occur in a normal scenario. What puzzles me is
> that it's not always reproducible. This makes me wonder what else is
> going on...

I've replaced the BUG_ON() with a WARN_ON_ONCE(), and made it be
unconditional (so you don't have to trigger the range check).

That might make it show up earlier and easier (and hopefully closer to
the place that causes it). Maybe that makes it easier for Srivatsa to
reproduce this. It doesn't make *my* machine do anything different,
though.

Srivatsa? It's in current -git.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
