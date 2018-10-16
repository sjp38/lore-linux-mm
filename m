Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5014F6B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:15:10 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f4-v6so21968124pff.2
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 17:15:10 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id f15-v6si12089832pgi.378.2018.10.15.17.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Oct 2018 17:15:09 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] selftests/vm: Add a test for MAP_FIXED_NOREPLACE
In-Reply-To: <20181015080724.GC18839@dhcp22.suse.cz>
References: <20181013133929.28653-1-mpe@ellerman.id.au> <20181015080724.GC18839@dhcp22.suse.cz>
Date: Tue, 16 Oct 2018 11:15:04 +1100
Message-ID: <87va62lpbr.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, jannh@google.com, linux-mm@kvack.org, khalid.aziz@oracle.com, aarcange@redhat.com, fweimer@redhat.com, jhubbard@nvidia.com, willy@infradead.org, abdhalee@linux.vnet.ibm.com, joel@jms.id.au, keescook@chromium.org, jasone@google.com, davidtgoldblatt@gmail.com, trasz@freebsd.org, danielmicay@gmail.com

Michal Hocko <mhocko@kernel.org> writes:

> On Sun 14-10-18 00:39:29, Michael Ellerman wrote:
>> Add a test for MAP_FIXED_NOREPLACE, based on some code originally by
>> Jann Horn. This would have caught the overlap bug reported by Daniel Micay.
>> 
>> I originally suggested to Michal that we create MAP_FIXED_NOREPLACE, but
>> instead of writing a selftest I spent my time bike-shedding whether it
>> should be called MAP_FIXED_SAFE/NOCLOBBER/WEAK/NEW .. mea culpa.
>
> You wer one of those to provide a useful feedback actually. So no reason
> to feel sorry. I should have been forced to write a test case instead.
> No idea why I haven't considered that myself actually. So I steal your
> culpa here.

Haha, plenty of culpa to go around :)

Yeah we should try to always have selftests for new flags and things
like this.

This one was a bit special because the original point of the new flag
was for the kernel to use internally, and we sort of forgot that we were
also adding a user-visible flag.

>> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
>
> Thanks for doing this!
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

cheers
