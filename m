Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C93CB6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:52:16 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g21so17747685ioe.12
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:52:16 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p20si6977159ioo.184.2017.08.10.03.52.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 03:52:13 -0700 (PDT)
Date: Thu, 10 Aug 2017 12:52:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170810105203.tlolkkgj6lslxa2s@hirez.programming.kicks-ass.net>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170809155059.yd7le2szn2rcd4h2@hirez.programming.kicks-ass.net>
 <20170810093707.GA20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810093707.GA20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Aug 10, 2017 at 06:37:07PM +0900, Byungchul Park wrote:
> On Wed, Aug 09, 2017 at 05:50:59PM +0200, Peter Zijlstra wrote:
> > 
> > 
> > Heh, look what it does...
> 
> Wait.. execuse me but.. is it a real problem?

I've not tried again with my patch removed -- I'm chasing another issue
atm. But note that I'm running this on tip/master which has a bunch of
hotplug lock rework in, and that sequence includes hotplug lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
