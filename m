Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD5C76B0335
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 23:50:14 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id x1so298951plb.2
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 20:50:14 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id k184si1228072pgd.173.2017.12.05.20.50.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Dec 2017 20:50:13 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
In-Reply-To: <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org> <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com> <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
Date: Wed, 06 Dec 2017 15:50:09 +1100
Message-ID: <87zi6we9z2.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

Michal Hocko <mhocko@kernel.org> writes:

> On Wed 29-11-17 14:25:36, Kees Cook wrote:
>> On Wed, Nov 29, 2017 at 6:42 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > The first patch introduced MAP_FIXED_SAFE which enforces the given
>> > address but unlike MAP_FIXED it fails with ENOMEM if the given range
>> > conflicts with an existing one. The flag is introduced as a completely
>> 
>> I still think this name should be better. "SAFE" doesn't say what it's
>> safe from...

Yes exactly.

> It is safe in a sense it doesn't perform any address space dangerous
> operations. mmap is _inherently_ about the address space so the context
> should be kind of clear.

So now you have to define what "dangerous" means.

>> MAP_FIXED_UNIQUE
>> MAP_FIXED_ONCE
>> MAP_FIXED_FRESH
>
> Well, I can open a poll for the best name, but none of those you are
> proposing sound much better to me. Yeah, naming sucks...

I think Kees and I both previously suggested MAP_NO_CLOBBER for the
modifier.

So the obvious option for this would be MAP_FIXED_NO_CLOBBER.

Which is a bit longer sure, but says more or less exactly what it does.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
