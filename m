Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id B71226B0068
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 11:22:57 -0400 (EDT)
Received: by weyu3 with SMTP id u3so3718916wey.14
        for <linux-mm@kvack.org>; Mon, 01 Oct 2012 08:22:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
 <alpine.LSU.2.00.1209192021270.28543@eggly.anvils> <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 1 Oct 2012 08:22:35 -0700
Message-ID: <CA+55aFymzvPgw5O=MmHsedOmheNMYXXmy3munR6XDt5tQYEESA@mail.gmail.com>
Subject: Re: [patch for-3.6] mm, thp: fix mapped pages avoiding unevictable
 list on mlock
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, Sep 26, 2012 at 6:40 PM, David Rientjes <rientjes@google.com> wrote:
>
> Ok, sounds good.  If there's no objection, I'd like to ask Andrew to apply
> this to -mm and remove the cc to stable@vger.kernel.org since the
> mlock_vma_page() problem above is separate and doesn't conflict with this
> code, so I'll send a followup patch to address that.

So I deferred this (and the "mm, thp: fix mlock statistics" one) to
after 3.6, because Andrea indicated that they aren't critical. Now I'd
be ready to take them, but I suspect they are already in Andrew's
queue and I can forget about them.

Please holler if I need to take the two thp patches directly..

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
