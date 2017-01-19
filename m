Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2A0E6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 20:54:38 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so39808584pfb.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 17:54:38 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c21si1912559pfd.231.2017.01.18.17.54.37
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 17:54:37 -0800 (PST)
Date: Thu, 19 Jan 2017 10:54:28 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20170119015428.GN3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-16-git-send-email-byungchul.park@lge.com>
 <20170118064230.GF15084@tardis.cn.ibm.com>
 <20170118105346.GL3326@X58A-UD3R>
 <20170118110317.GC6515@twins.programming.kicks-ass.net>
 <20170118115428.GM3326@X58A-UD3R>
 <20170118120757.GD6515@twins.programming.kicks-ass.net>
 <008101d27184$7d3cbd00$77b63700$@lge.com>
 <20170118141255.GE6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118141255.GE6515@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: 'Boqun Feng' <boqun.feng@gmail.com>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 03:12:55PM +0100, Peter Zijlstra wrote:
> On Wed, Jan 18, 2017 at 09:14:59PM +0900, byungchul.park wrote:
> 
> > +Example 3:
> > +
> > +   CONTEXT X		   CONTEXT Y
> > +   ---------		   ---------
> > +			   mutex_lock A
> > +   mutex_lock A
> > +   mutex_unlock A
> > +			   wait_for_complete B /* DEADLOCK */
> 
> Each line (across both columns) is a distinct point in time after the
> line before.
> 
> Therefore, this states that "mutex_unlock A" happens before
> "wait_for_completion B", which is clearly impossible.

I meant that all statements below mutex_lock A in X are already impossible.
So the order of those are meaningless. But.. I got what you mean.

> You don't have to remove everything after mutex_lock A, but the unlock
> must not happen before context Y does the unlock.

I will apply what you and boqun recommanded, from the next spin.

Thank you,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
