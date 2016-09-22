Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61DEE6B026D
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 23:00:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so142393482pfv.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 20:00:50 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id q17si1604536pfg.98.2016.09.21.20.00.48
        for <linux-mm@kvack.org>;
        Wed, 21 Sep 2016 20:00:49 -0700 (PDT)
Date: Thu, 22 Sep 2016 11:57:43 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160922025743.GO2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913150554.GI2794@worktop>
 <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
 <20160913193829.GA5016@twins.programming.kicks-ass.net>
 <CANrsvROL43uYXsU7-kmFbHFgiKARBXYHNeqL71V9GxGzBYEdNA@mail.gmail.com>
 <20160914081117.GK5008@twins.programming.kicks-ass.net>
 <20160919024102.GF2279@X58A-UD3R>
 <20160919085009.GT5016@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919085009.GT5016@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Mon, Sep 19, 2016 at 10:50:09AM +0200, Peter Zijlstra wrote:
> Clearly I'm still missing stuff...

By the way.. do I have to explain more? Lack of explanation?

It would be the best to consider 'all valid acquires', which can occur
deadlock, but it looks impossible without parsing all code in head.

So it would be the safest to rely on 'acquires which actually happened',
even though it might be 'random acquires' among all valid acquires.

This conservative appoach is exactly same as how original lockdep is doing.
Let me explain more if you doubt it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
