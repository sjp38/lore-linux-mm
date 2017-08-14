Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 734E76B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 03:30:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so121772019pge.9
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:30:21 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a90si4217835plc.816.2017.08.14.00.30.18
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 00:30:19 -0700 (PDT)
Date: Mon, 14 Aug 2017 16:29:00 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170814072900.GL20323@X58A-UD3R>
References: <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
 <20170810131737.skdyy4qcxlikbyeh@tardis>
 <20170811034328.GH20323@X58A-UD3R>
 <20170811080329.3ehu7pp7lcm62ji6@tardis>
 <20170811085201.GI20323@X58A-UD3R>
 <20170811094448.GJ20323@X58A-UD3R>
 <CANrsvRM4ijD0ym0HJySqjOfcCeUbGCc6bBppK43y5MqC5aB1gQ@mail.gmail.com>
 <20170814070522.wwj4as2hk2o7avlu@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814070522.wwj4as2hk2o7avlu@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Aug 14, 2017 at 03:05:22PM +0800, Boqun Feng wrote:
> > 1. Boqun's approach
> 
> My approach requires(additionally):
> 
> 	MAX_XHLOCKS_NR * sizeof(unsigned int) // because of the hist_id field in hist_lock
> 
> bytes per task.
> 
> > 2. Peterz's approach
> 
> And Peter's approach requires(additionally):
> 
> 	1 * sizeof(unsigned int)
> 
> bytes per task.
> 
> So basically we need some tradeoff between memory footprints and history
> precision here.

I see what you intended. Then, Peterz's one looks better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
