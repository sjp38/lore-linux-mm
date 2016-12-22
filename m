Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3830582F64
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 21:07:59 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b1so421514729pgc.5
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 18:07:59 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id f5si28816440plm.37.2016.12.21.18.07.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 18:07:58 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id w68so12251900pgw.3
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 18:07:58 -0800 (PST)
Date: Thu, 22 Dec 2016 12:07:40 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161222120740.024eba5a@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFwQtaKGDzNFsanMavTH=TBoHgjGqQbwqbLvbjs7Y0EWCw@mail.gmail.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
	<CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
	<156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
	<CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
	<CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
	<20161221080931.GQ3124@twins.programming.kicks-ass.net>
	<20161221083247.GW3174@twins.programming.kicks-ass.net>
	<CA+55aFx-YmpZ4NBU0oSw_iJV8jEMaL8qX-HCH=DrutQ65UYR5A@mail.gmail.com>
	<20161222043331.31aab9cc@roar.ozlabs.ibm.com>
	<20161222050130.49d93982@roar.ozlabs.ibm.com>
	<CA+55aFwQtaKGDzNFsanMavTH=TBoHgjGqQbwqbLvbjs7Y0EWCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Wed, 21 Dec 2016 11:50:49 -0800
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Dec 21, 2016 at 11:01 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
> > Peter's patch is less code and in that regard a bit nicer. I tried
> > going that way once, but I just thought it was a bit too sloppy to
> > do nicely with wait bit APIs.  
> 
> So I have to admit that when I read through your and PeterZ's patches
> back-to-back, yours was easier to understand.
> 
> PeterZ's is smaller but kind of subtle. The whole "return zero from
> lock_page_wait() and go around again" and the locking around that
> isn't exactly clear. In contrast, yours has the obvious waitqueue
> spinlock.
> 
> I'll think about it.  And yes, it would be good to have more testing,
> but at the same time xmas is imminent, and waiting around too much
> isn't going to help either..

Sure. Let's see if Dave and Mel get a chance to do some testing.

It might be a squeeze before Christmas. I realize we're going to fix
it anyway so on one hand might as well get something in. On the other
I didn't want to add a subtle bug then have everyone go on vacation.

How about I send up the page flag patch by Friday and that can bake
while the main patch gets more testing / review?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
