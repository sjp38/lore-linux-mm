Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B72F16B0006
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 17:53:38 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id h68so34173339qke.3
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:53:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor23216790qtc.0.2018.11.13.14.53.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 14:53:37 -0800 (PST)
Date: Tue, 13 Nov 2018 22:53:34 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Message-ID: <20181113225334.hnz7pqoldvvg6j3w@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
 <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name>
 <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi74gpvJv8=B-3pVSMrDssu-aYMxW9xM7mt1WNQjGLjMZqA@mail.gmail.com>
 <20181113183510.5y2hzruoi23e7o2t@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi763e4sZj1NHAk2fAjtPtb-kAZfcPq=KTH8B3sE-oDVvGw@mail.gmail.com>
 <20181113191653.btbzobquxtwt47z4@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi77JMyxU9L4bZHPv4Nt=tyQsEZDQcMVMRfQ7de_LjZg+-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGqmi77JMyxU9L4bZHPv4Nt=tyQsEZDQcMVMRfQ7de_LjZg+-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <timofey.titovets@synesis.ru>
Cc: Oleksandr Natalenko <oleksandr@natalenko.name>, Jann Horn <jannh@google.com>, linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

> > > That must work, but we out of bit space in vm_flags [1].
> > > i.e. first 32 bits already defined, and other only accessible only on
> > > 64-bit machines.
> >
> > So, grow vm_flags_t to 64-bit, or enable this feature on 64-bit only.
> 
> With all due respect to you, for that type of things we need
> mm maintainer opinion.

As far as I understood, you already got directions from the maintainers
to do similar to the way THP is implemented, and THP uses two flags:

VM_HUGEPAGE VM_NOHUGEPAGE, the same as I am thinking ksm should do if we
honor MADV_UNMERGEABLE.

When VM_NOHUGEPAGE is set khugepaged ignores those VMAs.

There may be a way to add VM_UNMERGEABLE without extending the size of
vm_flags, but that would be a good start point in looking how to add a
new flag.

Again, you could simply enable this feature on 64-bit only.

Pasha
