Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81F5A6B0006
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 02:59:56 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id l7-v6so308581lji.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 23:59:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m2-v6sor97623lfg.197.2018.08.01.23.59.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 23:59:55 -0700 (PDT)
MIME-Version: 1.0
References: <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1> <20180731174349.GA12944@agluck-desk>
 <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
In-Reply-To: <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
From: Amit Pundir <amit.pundir@linaro.org>
Date: Thu, 2 Aug 2018 12:29:18 +0530
Message-ID: <CAMi1Hd14yYr+LXTwjexMfFue9=PwoC7L8oscZhGm_eZ_is+v1A@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: tony.luck@intel.com, kirill@shutemov.name, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, willy@infradead.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, aarcange@redhat.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Wed, 1 Aug 2018 at 22:45, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I'd like to get this sorted out asap, although at this point I still
> think that I'll have to do an rc8 even though I feel like we may have
> caught everything.

No AOSP regressions in my limited smoke testing so far with
current HEAD: 6b4703768268 ("Merge branch 'fixes' of
git://git.armlinux.org.uk/~rmk/linux-arm"). Thanks.

Regards,
Amit Pundir
