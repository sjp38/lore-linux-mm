Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id C4B5F6B0039
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 02:04:25 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id u57so2242701wes.4
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 23:04:25 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id qb2si19265279wic.31.2014.06.05.23.04.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 23:04:24 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so316757wib.5
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 23:04:23 -0700 (PDT)
Date: Fri, 6 Jun 2014 08:04:19 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140606060419.GA3737@gmail.com>
References: <20140501123738.3e64b2d2@notabene.brown>
 <20140522090502.GB30094@gmail.com>
 <20140522195056.445f2dcb@notabene.brown>
 <20140605124509.GA1975@gmail.com>
 <20140606102303.09ef9fb3@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140606102303.09ef9fb3@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>


* NeilBrown <neilb@suse.de> wrote:

> On Thu, 5 Jun 2014 14:45:09 +0200 Ingo Molnar <mingo@kernel.org> wrote:
> 
> > 
> > * NeilBrown <neilb@suse.de> wrote:
> > 
> > > On Thu, 22 May 2014 11:05:02 +0200 Ingo Molnar <mingo@kernel.org> wrote:
> > > 
> > > > 
> > > > * NeilBrown <neilb@suse.de> wrote:
> > > > 
> > > > > [[ get_maintainer.pl suggested 61 email address for this patch.
> > > > >    I've trimmed that list somewhat.  Hope I didn't miss anyone
> > > > >    important...
> > > > >    I'm hoping it will go in through the scheduler tree, but would
> > > > >    particularly like an Acked-by for the fscache parts.  Other acks
> > > > >    welcome.
> > > > > ]]
> > > > > 
> > > > > The current "wait_on_bit" interface requires an 'action' function
> > > > > to be provided which does the actual waiting.
> > > > > There are over 20 such functions, many of them identical.
> > > > > Most cases can be satisfied by one of just two functions, one
> > > > > which uses io_schedule() and one which just uses schedule().
> > > > > 
> > > > > So:
> > > > >  Rename wait_on_bit and        wait_on_bit_lock to
> > > > >         wait_on_bit_action and wait_on_bit_lock_action
> > > > >  to make it explicit that they need an action function.
> > > > > 
> > > > >  Introduce new wait_on_bit{,_lock} and wait_on_bit{,_lock}_io
> > > > >  which are *not* given an action function but implicitly use
> > > > >  a standard one.
> > > > >  The decision to error-out if a signal is pending is now made
> > > > >  based on the 'mode' argument rather than being encoded in the action
> > > > >  function.
> > > > 
> > > > this patch fails to build on x86-32 allyesconfigs.
> > > 
> > > Could you share the build errors?
> > 
> > Sure, find it attached below.
> 
> Thanks.
> 
> It looks like this is a wait_on_bit usage that was added after I created the
> patch.
> 
> How about you drop my patch for now, we wait for -rc1 to come out, then I
> submit a new version against -rc1 and we get that into -rc2.
> That should minimise such conflicts.
> 
> Does that work for you?

Sure, that sounds like a good approach, if Linus doesn't object.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
