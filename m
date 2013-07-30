Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 3167D6B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 14:15:28 -0400 (EDT)
Date: Tue, 30 Jul 2013 14:05:04 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mlockall triggred rcu_preempt stall.
Message-ID: <20130730180504.GA4546@redhat.com>
References: <20130719145323.GA1903@redhat.com>
 <20130719221538.GH21367@linux.vnet.ibm.com>
 <20130720003212.GA31308@redhat.com>
 <20130730175718.GA8957@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730175718.GA8957@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com, walken@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Tue, Jul 30, 2013 at 10:57:18AM -0700, Paul E. McKenney wrote:
 > On Fri, Jul 19, 2013 at 08:32:12PM -0400, Dave Jones wrote:
 > > On Fri, Jul 19, 2013 at 03:15:39PM -0700, Paul E. McKenney wrote:
 > >  > On Fri, Jul 19, 2013 at 10:53:23AM -0400, Dave Jones wrote:
 > >  > > My fuzz tester keeps hitting this. Every instance shows the non-irq stack
 > >  > > came in from mlockall.  I'm only seeing this on one box, but that has more
 > >  > > ram (8gb) than my other machines, which might explain it.
 > >  > 
 > >  > Are you building CONFIG_PREEMPT=n?  I don't see any preemption points in
 > >  > do_mlockall(), so a range containing enough vmas might well stall the
 > >  > CPU in that case.  
 > > 
 > > That was with full preempt.
 > > 
 > >  > Does the patch below help?  If so, we probably need others, but let's
 > >  > first see if this one helps.  ;-)
 > > 
 > > I'll try it on Monday.
 > 
 > Any news?  If I don't hear otherwise, I will assume that the patch did
 > not help, and will therefore drop it.

I wasn't able to do any tests yesterday, because I kept hitting other oopses.
I've got patches for the more obvious ones now, so I'll start testing rc3 this
afternoon.

	Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
