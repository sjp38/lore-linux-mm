Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3AE6B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 07:59:01 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id v78-v6so4794904oia.8
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 04:59:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y110sor7439050otb.121.2018.11.13.04.59.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 04:59:00 -0800 (PST)
Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com. [209.85.167.174])
        by smtp.gmail.com with ESMTPSA id c58sm14255543otd.34.2018.11.13.04.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 04:58:57 -0800 (PST)
Received: by mail-oi1-f174.google.com with SMTP id r127-v6so10190985oie.3
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 04:58:57 -0800 (PST)
MIME-Version: 1.0
References: <20181112231344.7161-1-timofey.titovets@synesis.ru> <CAG48ez0VRmRQckOjQhOeaf6bLYkfi45ksdnzuCKPwBYTM+As1g@mail.gmail.com>
In-Reply-To: <CAG48ez0VRmRQckOjQhOeaf6bLYkfi45ksdnzuCKPwBYTM+As1g@mail.gmail.com>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Tue, 13 Nov 2018 15:58:20 +0300
Message-ID: <CAGqmi75MShkwHTiSLPiOoQuYORmYTBJVqMKXm7pKhoNg9PT3yw@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jannh@google.com
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 14:57, Jann =
Horn <jannh@google.com>:
>
> On Tue, Nov 13, 2018 at 12:40 PM Timofey Titovets
> <timofey.titovets@synesis.ru> wrote:
> > ksm by default working only on memory that added by
> > madvise().
> >
> > And only way get that work on other applications:
> >   * Use LD_PRELOAD and libraries
> >   * Patch kernel
> >
> > Lets use kernel task list and add logic to import VMAs from tasks.
> >
> > That behaviour controlled by new attributes:
> >   * mode:
> >     I try mimic hugepages attribute, so mode have two states:
> >       * madvise      - old default behaviour
> >       * always [new] - allow ksm to get tasks vma and
> >                        try working on that.
>
> Please don't. And if you really have to for some reason, put some big
> warnings on this, advising people that it's a security risk.
>
> KSM is one of the favorite punching bags of side-channel and hardware
> security researchers:
>
> As a gigantic, problematic side channel:
> http://staff.aist.go.jp/k.suzaki/EuroSec2011-suzaki.pdf
> https://www.usenix.org/system/files/conference/woot15/woot15-paper-barres=
i.pdf
> https://access.redhat.com/blogs/766093/posts/1976303
> https://gruss.cc/files/dedup.pdf
>
> In particular https://gruss.cc/files/dedup.pdf ("Practical Memory
> Deduplication Attacks in Sandboxed JavaScript") shows that KSM makes
> it possible to use malicious JavaScript to determine whether a given
> page of memory exists elsewhere on your system.
>
> And also as a way to target rowhammer-based faults:
> https://www.usenix.org/system/files/conference/usenixsecurity16/sec16_pap=
er_razavi.pdf
> https://thisissecurity.stormshield.com/2017/10/19/attacking-co-hosted-vm-=
hacker-hammer-two-memory-modules/

I'm very sorry, i'm not a security specialist.
But if i understood correctly, ksm have that security issues _without_
my patch set.
Even more, not only KSM have that type of issue, any memory
deduplication have that problems.
Any guy who care about security must decide on it self. Which things
him use and how he will
defend from others.
Even more on it self he must learn tools, what he use and make some
decision right?

So, if you really care about that problem in general, or only on KSM side,
that your initiative and your duty to warn people about that.

KSM already exists for 10+ years. You know about security implication
of use memory deduplication.
That your duty to send a patches to documentation, and add appropriate warn=
ings.

Sorry for my passive aggressive,
i don't try hurt someone, or humiliate.

That's just my IMHO and i'm just to restricted in my english knowledge,
to write that more gentle.

Thanks!
