Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFF26B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 01:18:22 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f21so43443554pgi.4
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 22:18:22 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u8si3755082plk.103.2017.02.28.22.18.20
        for <linux-mm@kvack.org>;
        Tue, 28 Feb 2017 22:18:21 -0800 (PST)
Date: Wed, 1 Mar 2017 15:18:04 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301061804.GF11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228154900.GL5680@worktop>
 <20170301051706.GD11663@X58A-UD3R>
MIME-Version: 1.0
In-Reply-To: <20170301051706.GD11663@X58A-UD3R>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Mar 01, 2017 at 02:17:07PM +0900, Byungchul Park wrote:
> On Tue, Feb 28, 2017 at 04:49:00PM +0100, Peter Zijlstra wrote:
> > On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > 
> > > +struct cross_lock {
> > > +	/*
> > > +	 * When more than one acquisition of crosslocks are overlapped,
> > > +	 * we do actual commit only when ref == 0.
> > > +	 */
> > > +	atomic_t ref;
> > 
> > That comment doesn't seem right, should that be: ref != 0 ?
> > Also; would it not be much clearer to call this: nr_blocked, or waiters
> > or something along those lines, because that is what it appears to be.

Honestly, I forgot why I introduced the ref.. I will remove the ref next
spin, and handle waiters in another way.

Thank you,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
