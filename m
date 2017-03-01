Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AABA16B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 07:11:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id w189so10192936pfb.4
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 04:11:13 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y184si4470360pfg.180.2017.03.01.04.11.11
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 04:11:12 -0800 (PST)
Date: Wed, 1 Mar 2017 21:10:58 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301121058.GJ11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228131012.GI5680@worktop>
 <20170228132444.GG3817@X58A-UD3R>
 <20170228182902.GN5680@worktop>
 <20170301044033.GC11663@X58A-UD3R>
 <20170301104548.GE6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
In-Reply-To: <20170301104548.GE6515@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Mar 01, 2017 at 11:45:48AM +0100, Peter Zijlstra wrote:
> On Wed, Mar 01, 2017 at 01:40:33PM +0900, Byungchul Park wrote:
> 
> > Right. I decided to force MAX_XHLOCKS_NR to be power of 2 and everything
> > became easy. Thank you very much.
> 
> Something like:
> 
> 	BUILD_BUG_ON(MAX_XHLOCKS_NR & (MAX_XHLOCK_NR - 1));
> 
> Should enforce I think.

Good idea! Thank you very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
