Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 357A86B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:22:48 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id o9so16437838iod.13
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 02:22:48 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k184si6077206iok.25.2017.08.10.02.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 02:22:47 -0700 (PDT)
Date: Thu, 10 Aug 2017 11:22:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170810092238.doii2nwmhalinz5f@hirez.programming.kicks-ass.net>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170809141605.7r3cldc4na3skcnp@hirez.programming.kicks-ass.net>
 <20170810013216.GX20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810013216.GX20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Aug 10, 2017 at 10:32:16AM +0900, Byungchul Park wrote:
> On Wed, Aug 09, 2017 at 04:16:05PM +0200, Peter Zijlstra wrote:
> > Hehe, _another_ scheme...
> > 
> > Yes I think this works.. but I had just sort of understood the last one.
> > 
> > How about I do this on top? That I think is a combination of what I
> > proposed last and your single invalidate thing. Combined they solve the
> > problem with the least amount of extra storage (a single int).
> 
> I'm sorry for saying that.. I'm not sure if this works well.

OK, I'll sit on the patch a little while, if you could share your
concerns then maybe I can improve the comments ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
