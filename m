Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1CE886B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 12:00:21 -0400 (EDT)
Subject: Re: [PATCH 2/2] rwsem: do optimistic spinning for writer lock
 acquisition
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130625073739.GX28407@twins.programming.kicks-ass.net>
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>
	 <1371858700.22432.5.camel@schen9-DESK>
	 <51C558E2.1040108@hurleysoftware.com>
	 <1372017836.1797.14.camel@buesod1.americas.hpqcorp.net>
	 <1372093876.22432.34.camel@schen9-DESK>
	 <51C894C3.4040407@hurleysoftware.com>
	 <1372105065.22432.65.camel@schen9-DESK>
	 <20130625073739.GX28407@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Jun 2013 09:00:06 -0700
Message-ID: <1372176006.22432.96.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Peter Hurley <peter@hurleysoftware.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Alex Shi <alex.shi@intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, 2013-06-25 at 09:37 +0200, Peter Zijlstra wrote:
> On Mon, Jun 24, 2013 at 01:17:45PM -0700, Tim Chen wrote:
> > On second thought, I agree with you.  I should change this to
> > something like
> > 
> > 	int retval = true;
> > 	task_struct *sem_owner;
> > 
> > 	/* Spin only if active writer running */
> > 	if (!sem->owner)
> > 		return false;
> > 
> > 	rcu_read_lock();
> > 	sem_owner = sem->owner;
> 
> That should be: sem_owner = ACCESS_ONCE(sem->owner); to make sure the
> compiler doesn't try and be clever and rereads.

Thanks.  Will incorporate this in next version of the patch.

Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
