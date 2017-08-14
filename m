Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCDCD6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 06:57:53 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id f38so4751222wrf.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 03:57:53 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id d9si5969859edb.202.2017.08.14.03.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 03:57:52 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id y206so13989195wmd.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 03:57:52 -0700 (PDT)
Date: Mon, 14 Aug 2017 12:57:48 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170814105748.zbnkjbgwbaxftu43@gmail.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170810111019.n376bsm6h4de2jvi@gmail.com>
 <20170810114504.GD20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810114504.GD20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> On Thu, Aug 10, 2017 at 01:10:19PM +0200, Ingo Molnar wrote:
> > 
> > * Byungchul Park <byungchul.park@lge.com> wrote:
> > 
> > > Change from v7
> > > 	- rebase on latest tip/sched/core (Jul 26 2017)
> > > 	- apply peterz's suggestions
> > > 	- simplify code of crossrelease_{hist/soft/hard}_{start/end}
> > > 	- exclude a patch avoiding redundant links
> > > 	- exclude a patch already applied onto the base
> > 
> > Ok, it's looking pretty good here now, there's one thing I'd like you to change, 
> > please remove all the new Kconfig dependencies:
> > 
> >  CONFIG_LOCKDEP_CROSSRELEASE=y
> >  CONFIG_LOCKDEP_COMPLETE=y
> > 
> > and make it all part of PROVE_LOCKING, like most of the other lock debugging bits.
> 
> OK. I will remove them. What about CONFIG_LOCKDEP_PAGELOCK? Should I also
> remove it?

So I'd only remove the forced _configurability_ - we can still keep those 
variables just fine. They modularize the code and they might be useful later on if 
for some reason there's some really bad performance aspect that would make one of 
these lockdep components to be configured out by default.

Just make the user interface sane - i.e. only one switch needed to enable full 
lockdep. Internal modularization is fine, as long as it's not ugly and the user is 
not burdened with it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
