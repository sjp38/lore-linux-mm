Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F21276B02C3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:25:30 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 77so17059319itj.4
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 02:25:30 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f1si7048593itf.14.2017.08.10.02.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 02:25:30 -0700 (PDT)
Date: Thu, 10 Aug 2017 11:25:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 11/14] lockdep: Apply crossrelease to PG_locked locks
Message-ID: <20170810092523.ktie2iqhefw5saop@hirez.programming.kicks-ass.net>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-12-git-send-email-byungchul.park@lge.com>
 <20170810013501.GY20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810013501.GY20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Aug 10, 2017 at 10:35:02AM +0900, Byungchul Park wrote:
> On Mon, Aug 07, 2017 at 04:12:58PM +0900, Byungchul Park wrote:
> > Although lock_page() and its family can cause deadlock, the lock
> > correctness validator could not be applied to them until now, becasue
> > things like unlock_page() might be called in a different context from
> > the acquisition context, which violates lockdep's assumption.
> > 
> > Thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can now apply the lockdep
> > detector to page locks. Applied it.
> 
> Is there any reason excluding applying it into PG_locked?

Wanted to start small.. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
