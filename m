Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4796B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 14:38:37 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so97613226igb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 11:38:36 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id w1si9209670igw.7.2015.04.28.11.38.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 11:38:35 -0700 (PDT)
Received: by iebrs15 with SMTP id rs15so25419668ieb.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 11:38:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150428183535.GB30918@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
	<1430223111-14817-1-git-send-email-mhocko@suse.cz>
	<CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
	<20150428164302.GI2659@dhcp22.suse.cz>
	<CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com>
	<20150428183535.GB30918@dhcp22.suse.cz>
Date: Tue, 28 Apr 2015 11:38:35 -0700
Message-ID: <CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com>
Subject: Re: Should mmap MAP_LOCKED fail if mm_poppulate fails?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, Apr 28, 2015 at 11:35 AM, Michal Hocko <mhocko@suse.cz> wrote:
>
> I am still not sure I see the problem here.

Basically, I absolutely hate the notion of us doing something
unsynchronized, when I can see us undoing a mmap that another thread
is doing. It's wrong.

You also didn't react to all the *other* things that were wrong in
that patch-set. The games you play with !fatal_signal_pending() etc
are just crazy.

End result: I absolutely detest the whole thing. I told you what I
consider an acceptable solution instead, that is much simpler and
doesn't have any of the problems of your patchset.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
