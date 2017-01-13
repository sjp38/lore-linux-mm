Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1E4B6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 21:45:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so94575804pfx.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 18:45:27 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e3si3695033pld.47.2017.01.12.18.45.26
        for <linux-mm@kvack.org>;
        Thu, 12 Jan 2017 18:45:26 -0800 (PST)
Date: Fri, 13 Jan 2017 11:45:18 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 05/15] lockdep: Make check_prev_add can use a separate
 stack_trace
Message-ID: <20170113024518.GB3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-6-git-send-email-byungchul.park@lge.com>
 <20170112161643.GB3144@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112161643.GB3144@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Thu, Jan 12, 2017 at 05:16:43PM +0100, Peter Zijlstra wrote:
> On Fri, Dec 09, 2016 at 02:12:01PM +0900, Byungchul Park wrote:
> > check_prev_add() saves a stack trace of the current. But crossrelease
> > feature needs to use a separate stack trace of another context in
> > check_prev_add(). So make it use a separate stack trace instead of one
> > of the current.
> > 
> 
> So I was thinking, can't we make check_prevs_add() create the stack
> trace unconditionally but record if we used it or not, and then return
> the entries when unused. All that is serialized by graph_lock anyway and
> that way we already pass a stack into check_prev_add() so we can easily
> pass in a different one.
> 
> I think that removes a bunch of tricky and avoids all the new tricky.

Looks very good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
