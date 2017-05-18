Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF236B0038
	for <linux-mm@kvack.org>; Thu, 18 May 2017 02:22:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l73so25508787pfj.8
        for <linux-mm@kvack.org>; Wed, 17 May 2017 23:22:17 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id h10si4309403pgc.45.2017.05.17.23.22.15
        for <linux-mm@kvack.org>;
        Wed, 17 May 2017 23:22:16 -0700 (PDT)
Date: Thu, 18 May 2017 15:22:05 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170518062205.GF28017@X58A-UD3R>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419142503.rqsrgjlc7ump7ijb@hirez.programming.kicks-ass.net>
 <20170424051102.GJ21430@X58A-UD3R>
 <20170424101747.iirvjjoq66x25w7n@hirez.programming.kicks-ass.net>
 <20170425054044.GK21430@X58A-UD3R>
 <20170516141846.GM4626@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
In-Reply-To: <20170516141846.GM4626@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, May 16, 2017 at 04:18:46PM +0200, Peter Zijlstra wrote:
> On Tue, Apr 25, 2017 at 02:40:44PM +0900, Byungchul Park wrote:
> > On Mon, Apr 24, 2017 at 12:17:47PM +0200, Peter Zijlstra wrote:
> 
> > > My complaint is mostly about naming.. and "hist_gen_id" might be a
> > > better name.
> > 
> > Ah, I also think the name, 'work_id', is not good... and frankly I am
> > not sure if 'hist_gen_id' is good, either. What about to apply 'rollback',
> > which I did for locks in irq, into works of workqueues? If you say yes,
> > I will try to do it.
> 
> If the rollback thing works, that's fine too. If it gets ugly, stick
> with something like 'hist_id'.

I really want to implement it with rollback.. But it also needs to
introduce new fields to distinguish between works which are all normal
process contexts.

I will do this with renaming instead of applying rollback.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
