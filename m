Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6FB16B034B
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 02:33:45 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id u74so732739lff.14
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 23:33:45 -0800 (PST)
Received: from mail01.prevas.se (mail01.prevas.se. [62.95.78.3])
        by mx.google.com with ESMTPS id t28si779328ljd.235.2017.12.05.23.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 23:33:38 -0800 (PST)
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
 <87zi6we9z2.fsf@concordia.ellerman.id.au>
From: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
Message-ID: <a3b3129a-2626-a65e-59b0-68aada523723@prevas.dk>
Date: Wed, 6 Dec 2017 08:33:37 +0100
MIME-Version: 1.0
In-Reply-To: <87zi6we9z2.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

On 2017-12-06 05:50, Michael Ellerman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
>> On Wed 29-11-17 14:25:36, Kees Cook wrote:
>> It is safe in a sense it doesn't perform any address space dangerous
>> operations. mmap is _inherently_ about the address space so the context
>> should be kind of clear.
> 
> So now you have to define what "dangerous" means.
> 
>>> MAP_FIXED_UNIQUE
>>> MAP_FIXED_ONCE
>>> MAP_FIXED_FRESH
>>
>> Well, I can open a poll for the best name, but none of those you are
>> proposing sound much better to me. Yeah, naming sucks...

I also don't like the _SAFE name - MAP_FIXED in itself isn't unsafe [1],
but I do agree that having a way to avoid clobbering (parts of) an
existing mapping is quite useful. Since we're bikeshedding names, how
about MAP_FIXED_EXCL, in analogy with the O_ flag.

[1] I like the analogy between MAP_FIXED and dup2 made in
<stackoverflow.com/questions/28575893>.

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
