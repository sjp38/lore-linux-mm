Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF486B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 06:23:29 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y86-v6so11108888pff.6
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 03:23:29 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id g79-v6si875657pfk.260.2018.10.12.03.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Oct 2018 03:23:27 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] mm: don't clobber partially overlapping VMA with MAP_FIXED_NOREPLACE
In-Reply-To: <CAG48ez04KK62doMwsTVN4nN8y_wmv7hn+4my2jk5VXKL0wP7Lg@mail.gmail.com>
References: <20181010152736.99475-1-jannh@google.com> <20181010171944.GJ5873@dhcp22.suse.cz> <CAG48ez04KK62doMwsTVN4nN8y_wmv7hn+4my2jk5VXKL0wP7Lg@mail.gmail.com>
Date: Fri, 12 Oct 2018 21:23:21 +1100
Message-ID: <87tvlr1n1i.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, Michal Hocko <mhocko@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Khalid Aziz <khalid.aziz@oracle.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, abdhalee@linux.vnet.ibm.com, joel@jms.id.au, Kees Cook <keescook@chromium.org>, jasone@google.com, davidtgoldblatt@gmail.com, trasz@freebsd.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>, kernel list <linux-kernel@vger.kernel.org>

Jann Horn <jannh@google.com> writes:
> On Wed, Oct 10, 2018 at 7:19 PM Michal Hocko <mhocko@suse.com> wrote:
>> On Wed 10-10-18 17:27:36, Jann Horn wrote:
>> > Daniel Micay reports that attempting to use MAP_FIXED_NOREPLACE in an
>> > application causes that application to randomly crash. The existing check
>> > for handling MAP_FIXED_NOREPLACE looks up the first VMA that either
>> > overlaps or follows the requested region, and then bails out if that VMA
>> > overlaps *the start* of the requested region. It does not bail out if the
>> > VMA only overlaps another part of the requested region.
>>
>> I do not understand. Could you give me an example?
>
> Sure.
>
> =======
> user@debian:~$ cat mmap_fixed_simple.c
> #include <sys/mman.h>
> #include <errno.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>

..

Mind if I turn that into a selftest?

cheers
