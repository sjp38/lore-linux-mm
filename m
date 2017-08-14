Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC7E06B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:12:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r133so129565263pgr.6
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:12:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 37si4446181plv.446.2017.08.14.04.12.04
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 04:12:04 -0700 (PDT)
Date: Mon, 14 Aug 2017 20:10:46 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170814111046.GM20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170810111019.n376bsm6h4de2jvi@gmail.com>
 <20170810114504.GD20323@X58A-UD3R>
 <20170814105748.zbnkjbgwbaxftu43@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814105748.zbnkjbgwbaxftu43@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Aug 14, 2017 at 12:57:48PM +0200, Ingo Molnar wrote:
> 
> * Byungchul Park <byungchul.park@lge.com> wrote:
> 
> > On Thu, Aug 10, 2017 at 01:10:19PM +0200, Ingo Molnar wrote:
> > > 
> > > * Byungchul Park <byungchul.park@lge.com> wrote:
> > > 
> > > > Change from v7
> > > > 	- rebase on latest tip/sched/core (Jul 26 2017)
> > > > 	- apply peterz's suggestions
> > > > 	- simplify code of crossrelease_{hist/soft/hard}_{start/end}
> > > > 	- exclude a patch avoiding redundant links
> > > > 	- exclude a patch already applied onto the base
> > > 
> > > Ok, it's looking pretty good here now, there's one thing I'd like you to change, 
> > > please remove all the new Kconfig dependencies:
> > > 
> > >  CONFIG_LOCKDEP_CROSSRELEASE=y
> > >  CONFIG_LOCKDEP_COMPLETE=y
> > > 
> > > and make it all part of PROVE_LOCKING, like most of the other lock debugging bits.
> > 
> > OK. I will remove them. What about CONFIG_LOCKDEP_PAGELOCK? Should I also
> > remove it?
> 
> So I'd only remove the forced _configurability_ - we can still keep those 
> variables just fine. They modularize the code and they might be useful later on if 
> for some reason there's some really bad performance aspect that would make one of 
> these lockdep components to be configured out by default.
> 
> Just make the user interface sane - i.e. only one switch needed to enable full 
> lockdep. Internal modularization is fine, as long as it's not ugly and the user is 
> not burdened with it.

Agree.

Thank you,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
