Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4B36B0339
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 23:51:47 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r88so2012611pfi.23
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 20:51:47 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id v77si1345722pfa.223.2017.12.05.20.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Dec 2017 20:51:46 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
In-Reply-To: <20171201152640.GA3765@rei>
References: <20171129144219.22867-1-mhocko@kernel.org> <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com> <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei>
Date: Wed, 06 Dec 2017 15:51:44 +1100
Message-ID: <87wp20e9wf.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

Cyril Hrubis <chrubis@suse.cz> writes:

> Hi!
>> > MAP_FIXED_UNIQUE
>> > MAP_FIXED_ONCE
>> > MAP_FIXED_FRESH
>> 
>> Well, I can open a poll for the best name, but none of those you are
>> proposing sound much better to me. Yeah, naming sucks...
>
> Given that MAP_FIXED replaces the previous mapping MAP_FIXED_NOREPLACE
> would probably be a best fit.

Yeah that could work.

I prefer "no clobber" as I just suggested, because the existing
MAP_FIXED doesn't politely "replace" a mapping, it destroys the current
one - which you or another thread may be using - and clobbers it with
the new one.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
