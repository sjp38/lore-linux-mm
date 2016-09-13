Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB75D6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 08:10:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x24so419875329pfa.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:10:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c128si27324851pfc.233.2016.09.13.05.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 05:10:03 -0700 (PDT)
Date: Tue, 13 Sep 2016 14:09:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160913120956.GA5020@twins.programming.kicks-ass.net>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913100520.GA5035@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160913100520.GA5035@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Sep 13, 2016 at 12:05:20PM +0200, Peter Zijlstra wrote:
> On Tue, Sep 13, 2016 at 06:45:06PM +0900, Byungchul Park wrote:
> > Crossrelease feature calls a lock 'crosslock' if it is releasable
> > in any context. For crosslock, all locks having been held in the
> > release context of the crosslock, until eventually the crosslock
> > will be released, have dependency with the crosslock.
> > 
> > Using crossrelease feature, we can detect deadlock possibility even
> > for lock_page(), wait_for_complete() and so on.
> > 
> 
> Completely inadequate.
> 
> Please explain how cross-release does what it does. Talk about lock
> graphs and such.
> 
> I do not have time to reverse engineer this stuff.

Blergh, I'll do it anyway.. hold on for an email asking specific
questions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
